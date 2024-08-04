defmodule OrbShowcaseWeb.AriaWidgetsController do
  use OrbShowcaseWeb, :controller

  def menu(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.MenuButton)
    # wasm = Orb.to_wasm(OrbShowcase.Widgets.MenuButton)

    wasm = menu_wasm()
    html = execute_wasm(wasm)

    conn
    |> assign(:wat, wat)
    |> assign(:wasm_size, byte_size(wasm))
    |> assign(:widget_html, html)
    |> render(:menu)
  end

  def menu_wasm(conn, _params) do
    wasm = menu_wasm()

    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(200, wasm)
  end

  defp execute_wasm(wasm) do
    {:ok, pid} = Wasmex.start_link(%{bytes: wasm})

    {:ok, [ptr, len]} = Wasmex.call_function(pid, :text_html, [])

    {:ok, memory} = Wasmex.memory(pid)
    {:ok, store} = Wasmex.store(pid)
    html = Wasmex.Memory.read_binary(store, memory, ptr, len)
    html
  end

  defp menu_wasm() do
    wat = Orb.to_wat(OrbShowcase.Widgets.MenuButton)

    base_path = System.tmp_dir!()
    path_wat = Path.join(base_path, "menu.wat")
    path_wasm = Path.join(base_path, "menu.wasm")
    File.write!(path_wat, wat)
    System.cmd("wat2wasm", [path_wat], cd: base_path)
    wasm = File.read!(path_wasm)
    wasm
  end
end
