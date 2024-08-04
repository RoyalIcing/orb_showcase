defmodule OrbShowcaseWeb.Wasm.HTML do
  use OrbShowcaseWeb, :html

  attr :wasm, :string, required: true

  def html(assigns) do
    ~H"""
    <%= raw(execute_wasm(@wasm)) %>
    """
  end

  defp execute_wasm(wasm) do
    {:ok, pid} = Wasmex.start_link(%{bytes: wasm})

    {:ok, [ptr, len]} = Wasmex.call_function(pid, :text_html, [])

    {:ok, memory} = Wasmex.memory(pid)
    {:ok, store} = Wasmex.store(pid)
    html = Wasmex.Memory.read_binary(store, memory, ptr, len)
    html
  end
end
