defmodule OrbShowcaseWeb.Wasm.HTML do
  use OrbShowcaseWeb, :html

  attr :wasm, :string, required: true
  attr :transform, :any, default: &Function.identity/1

  def html(assigns) do
    ~H"""
    <%= raw(execute_wasm(@wasm, :text_html, @transform)) %>
    """
  end

  defp execute_wasm(wasm, function, transform)
       when is_binary(wasm) and is_atom(function) and is_function(transform) do
    {:ok, pid} = Wasmex.start_link(%{bytes: wasm})

    {:ok, [ptr, len]} = Wasmex.call_function(pid, function, [])

    {:ok, memory} = Wasmex.memory(pid)
    {:ok, store} = Wasmex.store(pid)
    html = Wasmex.Memory.read_binary(store, memory, ptr, len)
    html = transform.(html)
    html
  end
end
