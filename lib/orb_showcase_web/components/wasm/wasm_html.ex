defmodule OrbShowcaseWeb.Wasm.HTML do
  use OrbShowcaseWeb, :html

  attr :wasm, :string, required: true

  def html(assigns) do
    ~H"""
    <%= raw(execute_wasm(@wasm, :text_html)) %>
    """
  end

  defp execute_wasm(wasm, function) when is_binary(wasm) and is_atom(function) do
    {:ok, pid} = Wasmex.start_link(%{bytes: wasm})

    {:ok, [ptr, len]} = Wasmex.call_function(pid, function, [])

    {:ok, memory} = Wasmex.memory(pid)
    {:ok, store} = Wasmex.store(pid)
    html = Wasmex.Memory.read_binary(store, memory, ptr, len)
    html
  end
end
