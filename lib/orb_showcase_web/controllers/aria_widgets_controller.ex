defmodule OrbShowcaseWeb.AriaWidgetsController do
  use OrbShowcaseWeb, :controller

  def menu(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.MenuButton)
    # wasm = Orb.to_wasm(OrbShowcase.Widgets.MenuButton)

    wasm = do_menu_wasm()

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
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

  def combobox(conn, params) do
    locale = params["locale"] |> dbg()

    if locale do
      Process.put(:locale, locale)
    end

    wat = Orb.to_wat(OrbShowcase.Widgets.Combobox)
    # wasm = Orb.to_wasm(OrbShowcase.Widgets.Combobox)

    wasm = do_combobox_wasm(locale)

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
    |> assign(:transform_html, fn html ->
      case locale do
        nil ->
          html

        locale ->
          html |> String.replace("combobox.wasm", "combobox.wasm?locale=#{locale}")
      end
    end)
    |> render(:combobox)
  end

  def combobox_wasm(conn, params) do
    dbg(params)
    locale = params["locale"]
    wasm = do_combobox_wasm(locale)

    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(200, wasm)
  end

  defp do_combobox_wasm(locale) do
    if locale do
      Process.put(:locale, locale)
    end

    OrbShowcase.Widgets.Combobox
    |> Orb.to_wat()
    |> OrbShowcase.WasmRegistry.wat_to_wasm()
  end

  def calendar_grid(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.CalendarGrid)

    wasm = do_calendar_grid_wasm()

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
    |> render(:calendar_grid)
  end

  def calendar_grid_wasm(conn, _params) do
    wasm(conn, do_calendar_grid_wasm())
  end

  defp do_calendar_grid_wasm() do
    OrbShowcase.Widgets.CalendarGrid
    |> Orb.to_wat()
    |> OrbShowcase.WasmRegistry.wat_to_wasm()
  end

  def react(conn, _params) do
    conn
    |> render(:react)
  end

  defp wasm(conn, wasm_bytes) do
    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(conn.status || 200, wasm_bytes)
  end

  ####

  def accordion(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.Accordion)

    wasm = do_accordion_wasm()

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
    |> render(:menu)
  rescue
    e ->
      wat = Orb.to_wat(OrbShowcase.Widgets.Accordion)
      text(conn, wat)
  end

  def accordion_wasm(conn, _params) do
    wasm = do_accordion_wasm()

    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(200, wasm)
  end

  defp do_accordion_wasm() do
    OrbShowcase.Widgets.Accordion
    |> Orb.to_wat()
    |> OrbShowcase.WasmRegistry.wat_to_wasm()
  end

  # Counter

  def counter(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.Counter)

    wasm = do_counter_wasm()

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
    |> render(:menu)
  rescue
    e ->
      wat = Orb.to_wat(OrbShowcase.Widgets.Counter)
      text(conn, wat)
  end

  def counter_wasm(conn, _params) do
    wasm = do_counter_wasm()

    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(200, wasm)
  end

  defp do_counter_wasm() do
    OrbShowcase.Widgets.Counter
    |> Orb.to_wat()
    |> OrbShowcase.WasmRegistry.wat_to_wasm()
  end

  # Tabs

  def tabs(conn, _params) do
    wat = Orb.to_wat(OrbShowcase.Widgets.Tabs)

    wasm = do_tabs_wasm()

    conn
    |> assign(:wat, wat)
    |> assign(:wasm, wasm)
    |> render(:menu)
  rescue
    e ->
      wat = Orb.to_wat(OrbShowcase.Widgets.Tabs)
      text(conn, wat)
  end

  def tabs_wasm(conn, _params) do
    wasm = do_tabs_wasm()

    conn
    |> put_resp_content_type("application/wasm", nil)
    |> send_resp(200, wasm)
  end

  defp do_tabs_wasm() do
    OrbShowcase.Widgets.Tabs
    |> Orb.to_wat()
    |> OrbShowcase.WasmRegistry.wat_to_wasm()
  end
end
