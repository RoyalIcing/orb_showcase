defmodule OrbShowcase.Widgets.Source do
  @source_menu_button File.read!(Path.join(__DIR__, "menu_button.ex"))

  def menu_button(), do: @source_menu_button
end
