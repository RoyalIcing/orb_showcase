import { MemoryIO } from "./wasm/memoryIO";

const kebabize = (str) => str.replace(/[A-Z]+(?![a-z])|[A-Z]/g, ($, ofs) => (ofs ? "-" : "") + $.toLowerCase())

class GoldenOrb extends HTMLElement {
    connectedCallback() {
        const wasmURL = this.querySelector("source[type='application/wasm']")?.src;
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
            });

        const aborter = new AbortController();
        this.aborter = aborter;
        const { signal } = aborter;

        this.addEventListener("click", (event) => {
            const action = event.target.dataset.action;
            if (typeof action === "string") {
                this.exports[action]?.apply();
                this.update();
            }
        }, { signal });

        this.addEventListener("keydown", (event) => {
            const { target, key } = event;
            console.log(key, event.type);

            const specificActionKey = event.type + key;
            const specificActionAttribute = kebabize(specificActionKey);

            const action = target.closest(`[data-${specificActionAttribute}]`)?.dataset[specificActionKey] || target.dataset.action;

            // const action = dataset[specificActionKey] || dataset.action;

            if (typeof action === "string") {
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

        const string = reader.text_html();
        this.innerHTML = string;

        const focusID = reader.focus_id();
        console.log(string)
        console.log(focusID)

        document.getElementById(focusID)?.focus();
        console.log(document.activeElement);
    }
}

window.customElements.define('golden-orb', GoldenOrb);
