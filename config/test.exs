import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :orb_showcase, OrbShowcaseWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "2nNk8BTVzi8gSxD3Ye/xU8aTj9jy1DwrE6FeCIj/bpeCI04qvKsYD2HhF9RK1I29",
  server: false

# In test we don't send emails
config :orb_showcase, OrbShowcase.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
