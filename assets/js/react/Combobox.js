import React from "react"

const { useEffect, useId } = React;

// "<lipid-combobox>\n"
//   "<golden-orb>\n"
//   ~s|<source type="application/wasm" src="/combobox.wasm">\n|

const promises = new Map();

export function Combobox() {
    // const id = useId();
    // useEffect(() => {
    //     if (promises.has(id)) return;

    //     const promise = 
    // });

    return <lipid-combobox>
        <golden-orb>
            <source type="application/wasm" src="/combobox.wasm" />
        </golden-orb>
    </lipid-combobox>
}

export const comboboxEl = <Combobox />;