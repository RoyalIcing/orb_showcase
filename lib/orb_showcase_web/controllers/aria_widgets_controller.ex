defmodule OrbShowcaseWeb.AriaWidgetsController do
  use OrbShowcaseWeb, :controller

  def menu(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.MenuButton)
    # wasm = Orb.to_wasm(OrbShowcase.Widgets.MenuButton)

    wasm = menu_wasm()

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
    |> assign(:wasm_size, byte_size(wasm))
    |> render(:menu)
  end

  def menu_wasm(conn, _params) do
    wasm = menu_wasm()

    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(200, wasm)
  end

  defp menu_wasm() do
    OrbShowcase.Widgets.MenuButton
    |> Orb.to_wat()
    |> OrbShowcase.WasmRegistry.wat_to_wasm()
  end
end
