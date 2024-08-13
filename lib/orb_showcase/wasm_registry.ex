defmodule OrbShowcase.WasmRegistry do
  def wat_to_wasm(wat) do
    key = {:wat, wat}

    case Registry.meta(__MODULE__, key) do
      {:ok, wasm} ->
        wasm

      :error ->
        base_path = System.tmp_dir!()
        base_name = :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
        path_wat = Path.join(base_path, "#{base_name}.wat")
        path_wasm = Path.join(base_path, "#{base_name}.wasm")
        File.write!(path_wat, wat)
        System.cmd("wat2wasm", [path_wat], cd: base_path)
        wasm = File.read!(path_wasm)
        Registry.put_meta(__MODULE__, key, wasm)
        wasm
    end
  end
end
