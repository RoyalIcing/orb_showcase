defmodule OrbShowcaseWeb.Router do
  use OrbShowcaseWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {OrbShowcaseWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", OrbShowcaseWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

    get("/menu", AriaWidgetsController, :menu)
    get("/menu.wasm", AriaWidgetsController, :menu_wasm)

    get("/combobox", AriaWidgetsController, :combobox)
    get("/combobox.wasm", AriaWidgetsController, :combobox_wasm)

    get("/calendar-grid", AriaWidgetsController, :calendar_grid)
    get("/calendar-grid.wasm", AriaWidgetsController, :calendar_grid_wasm)

    get("/react", AriaWidgetsController, :react)

    get("/generate", GeneratorController, :create)
    get("/accordion", AriaWidgetsController, :accordion)
    get("/accordion.wasm", AriaWidgetsController, :accordion_wasm)
    get("/counter", AriaWidgetsController, :counter)
    get("/counter.wasm", AriaWidgetsController, :counter_wasm)
    get("/tabs", AriaWidgetsController, :tabs)
    get("/tabs.wasm", AriaWidgetsController, :tabs_wasm)
  end

  # Other scopes may use custom stacks.
  # scope "/api", OrbShowcaseWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:orb_showcase, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: OrbShowcaseWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
