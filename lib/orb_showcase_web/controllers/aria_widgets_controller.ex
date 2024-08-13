defmodule OrbShowcaseWeb.AriaWidgetsController do
  use OrbShowcaseWeb, :controller

  def menu(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.MenuButton)
    # wasm = Orb.to_wasm(OrbShowcase.Widgets.MenuButton)

    wasm = do_menu_wasm()

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
    |> assign(:wasm_size, byte_size(wasm))
    |> render(:menu)
  end

  def menu_wasm(conn, _params) do
    wasm = do_menu_wasm()

    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(200, wasm)
  end

  defp do_menu_wasm() do
    OrbShowcase.Widgets.MenuButton
    |> Orb.to_wat()
    |> OrbShowcase.WasmRegistry.wat_to_wasm()
  end

  def combobox(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.Combobox)
    # wasm = Orb.to_wasm(OrbShowcase.Widgets.Combobox)

    wasm = do_combobox_wasm()

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
    |> render(:combobox)
  end

  def combobox_wasm(conn, _params) do
    wasm = do_combobox_wasm()

    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(200, wasm)
  end

  defp do_combobox_wasm() do
    OrbShowcase.Widgets.Combobox
    |> Orb.to_wat()
    |> OrbShowcase.WasmRegistry.wat_to_wasm()
  end
end
