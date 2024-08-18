import { MemoryIO } from "./wasm/memoryIO";

const kebabize = (str) => str.replace(/[A-Z]+(?![a-z])|[A-Z]/g, ($, ofs) => (ofs ? "-" : "") + $.toLowerCase())

class GoldenOrb extends HTMLElement {
    connectedCallback() {
        const wasmURL = this.querySelector("source[type='application/wasm']")?.src;
        console.log("GoldenOrb connected", wasmURL)
        if (!wasmURL) throw Error("Expected WebAssembly .wasm URL");

        this.instance = { exports: {} };

        WebAssembly.instantiateStreaming(fetch(wasmURL, { credentials: "omit" }))
            .then(({ instance }) => {
                this.instance = instance;
                const memoryIO = new MemoryIO(instance.exports.memory);
                this.memory = memoryIO;
                this.reader = new Proxy(memoryIO, {
                    get(target, prop, receiver) {
                        return () => {
                            const [ptr, len] = instance.exports[prop]();
                            const string = target.readString(ptr, len);
                            return string;
                        }
                    },
                });

                window.requestAnimationFrame(this.update.bind(this));
            });

        const aborter = new AbortController();
        this.aborter = aborter;
        const { signal } = aborter;

        this.addEventListener("click", (event) => {
            const { target } = event;
            const action = target.closest(`[data-action]`)?.dataset?.action;

            if (typeof action === "string") {
                this.exports[action]?.apply();
                this.update();
            }
        }, { signal });

        this.addEventListener("input", (event) => {
            const { target } = event;

            const action = target.dataset.inputWrite;
            if (typeof action === "string") {
                console.log("calling", action, this.exports);
                const result = this.exports[action]?.apply();
                if (!Array.isArray(result) || result.length !== 2) {
                    throw Error(`Expected input write action ${action} to return (str_ptr, str_len) tuple.`)
                }

                this.memory.writeStringAt(target.value, result[0], result[1]);

                this.update();
            }
        }, { signal });

        this.addEventListener("keydown", (event) => {
            const { target, key } = event;
            console.log(key, event.type);

            const specificActionKey = event.type + key;
            const specificActionAttribute = kebabize(specificActionKey);

            // const action = target.closest(`[data-${specificActionAttribute}]`)?.dataset[specificActionKey] || target.dataset.action;
            const action = target.closest(`[data-${specificActionAttribute}]`)?.dataset[specificActionKey];

            // const action = dataset[specificActionKey] || dataset.action;

            console.log("action:", action);

            if (typeof action === "string") {
                event.preventDefault();

                console.log("calling", action, this.exports);
                this.exports[action]?.apply();
                this.update();
            }
        }, { signal });

        this.addEventListener("pointerover", (event) => {
            const { target, key } = event;
            console.log(key, event.type);
            const suffix = key || "";

            const specificActionKey = event.type + suffix;
            const specificActionAttribute = kebabize(specificActionKey);

            const foundTarget = target.closest(`[data-${specificActionAttribute}]`);
            if (!foundTarget) return;
            const action = foundTarget.dataset[specificActionKey] || target.dataset.action;

            // const action = dataset[specificActionKey] || dataset.action;

            if (typeof action === "string") {
                const [exportName, argsJSON] = action.split(":");

                if (argsJSON) {
                    const args = JSON.parse(argsJSON);

                    console.log("calling", exportName, args, this.exports);
                    this.exports[exportName]?.apply(...args);

                } else {
                    console.log("calling", exportName, this.exports);
                    this.exports[exportName]?.apply();
                }

                this.update();
            }
        }, { signal });
    }

    disconnectedCallback() {
        if (this.aborter) {
            this.aborter.abort();
            this.aborter = undefined;
        }
    }

    get exports() { return this.instance.exports }

    update() {
        const { reader } = this;
        if (!reader) return;

        const html = reader.text_html();

        const focused = document.activeElement;
        const focusedID = focused?.id;
        const selectionStart = focused?.selectionStart;
        const selectionEnd = focused?.selectionEnd;

        // console.log(html);

        // TODO: find golden-orb element and replace just that.
        // this.innerHTML = html;
        // window.morphdom(this, html);

        const range = document.createRange();
        const fragment = range.createContextualFragment(html);
        const newGoldenOrb = fragment.querySelector("golden-orb");

        console.log(this.querySelectorAll(":not(source)"))
        if (this.querySelectorAll(":not(source)").length === 0) {
            this.innerHTML = newGoldenOrb.innerHTML;
        } else {

            // this.innerHTML = newGoldenOrb.innerHTML;

            function* eachNode(a, b) {
                while (a) {
                    yield { a, b };

                    if (a.firstChild) {
                        yield* eachNode(a.firstChild, b.firstChild);
                    }

                    a = a.nextSibling;
                    b = b.nextSibling;
                }
            }

            for (const { a, b } of eachNode(newGoldenOrb, this)) {
                if (a.nodeType === 1) {
                    const previousAttributes = new Set(Array.from(b.attributes, attr => attr.name));

                    for (const attr of a.attributes) {
                        if (b.getAttribute(attr.name) !== attr.value) {
                            b.setAttribute(attr.name, attr.value);
                            console.log(attr.name, attr.value);
                        }
                        previousAttributes.delete(attr.name);
                    }

                    for (const attrToRemove of previousAttributes) {
                        b.removeAttribute(attrToRemove);
                    }
                }
            }
        }

        const focusID = reader.focus_id() || focusedID;
        // console.log(html);
        console.log(focusID);

        document.getElementById(focusID)?.focus();
        // console.log(document.activeElement);

        if (typeof document.activeElement?.setSelectionRange === "function" && selectionStart != null && selectionEnd != null) {
            document.activeElement.setSelectionRange(selectionStart, selectionEnd);
        }
    }
}

window.customElements.define('golden-orb', GoldenOrb);
