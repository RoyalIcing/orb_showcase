defmodule OrbShowcaseWeb.GeneratorController do
  use OrbShowcaseWeb, :controller

  import Phoenix.LiveView.Controller

  alias OrbShowcaseWeb.GeneratorLive

  def create(conn, _params) do
    conn |> put_layout(html: false) |> live_render(GeneratorLive)
  end
end
