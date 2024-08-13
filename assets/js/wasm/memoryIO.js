const utf8Encoder = new TextEncoder();
const utf8Decoder = new TextDecoder();

export class MemoryIO {
  constructor(memory) {
    this.memoryBytes = new Uint8Array(memory.buffer);
  }

  readString(ptr, len) {
    const { memoryBytes } = this;
    // Get subsection of memory between start and end, and decode it as UTF-8.
    return utf8Decoder.decode(memoryBytes.subarray(ptr, ptr + len));
  }

  writeStringAt(stringValue, memoryOffset, maximum = Infinity) {
    const { memoryBytes } = this;

    stringValue = stringValue.toString();
    const bytes = utf8Encoder.encode(stringValue);
    if (bytes.byteLength > maximum) {
      throw Error(`Unable to write string to WebAssembly memory of byte length ${bytes.byteLength} as it over maximum ${maximum}.`);
    }

    utf8Encoder.encodeInto(stringValue, memoryBytes.subarray(memoryOffset));
    // TODO: do we have to write nul-byte?
    memoryBytes[memoryOffset + bytes.length] = 0x0;
    return bytes.byteLength;
  }
}
