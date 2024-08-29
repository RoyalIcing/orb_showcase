defmodule OrbShowcaseWeb.AriaWidgetsHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use OrbShowcaseWeb, :html

  alias OrbShowcaseWeb.Wasm.HTML, as: GoldenOrb

  embed_templates "aria_widgets_html/*"
end
