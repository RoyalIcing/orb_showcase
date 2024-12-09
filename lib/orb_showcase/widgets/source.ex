defmodule OrbShowcase.Widgets.Source do
  @source_menu_button File.read!(Path.join(__DIR__, "menu_button.ex"))
  @source_combobox File.read!(Path.join(__DIR__, "combobox.ex"))
  @source_tabs File.read!(Path.join(__DIR__, "tabs.ex"))
  @source_calendar_grid File.read!(Path.join(__DIR__, "calendar_grid.ex"))

  def menu_button(), do: @source_menu_button
  def tabs(), do: @source_tabs
end
