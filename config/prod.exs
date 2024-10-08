import Config

# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix assets.deploy` task,
# which you should run after static files are built and
# before starting your production server.
config :orb_showcase, OrbShowcaseWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: OrbShowcase.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :mix_systemd,
  app_user: "caddy",
  app_group: "caddy",
  # base_dir: "/srv",
  # base_dir: "/opt",
  dirs: [
    :configuration,
    :logs,
    :runtime,
    :cache,
    :tmp
  ],
  env_files: [
    # Load environment vars from /srv/mix-deploy-example/etc/environment
    ["-", :configuration_dir, "/environment"]
  ],
  env_vars: [
    "PHX_SERVER=true"
    # "PORT=8080",
  ]

config :mix_deploy,
  app_user: "caddy",
  app_group: "caddy",
  # Copy config/environment to /etc/foo/environment
  copy_files: [
    %{
      src: "config/environment",
      dst: [:configuration_dir, "/environment"],
      user: "$DEPLOY_USER",
      group: "$APP_GROUP",
      mode: "640"
    }
  ],
  # Generate these scripts in bin
  templates: [
    "init-local",
    "create-users",
    "create-dirs",
    "copy-files",
    "enable",
    "release",
    "restart",
    "rollback",
    "start",
    "stop"
  ]
