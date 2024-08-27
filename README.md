# OrbShowcase

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:8344`](http://localhost:8344) from your browser.

## Production deploy

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

```bash
# Caddy public server
cd /root
micro Caddyfile
caddy fmt --overwrite
caddy reload

# Elixir application
cd /var/www/orb_showcase
git pull --rebase

# Regenerate systemd and bin scripts
MIX_ENV=prod mix systemd.generate
MIX_ENV=prod mix deploy.generate

# Change environment
micro config/environment
bin/deploy-copy-files

# Release new version
mix deps.get
npm ci --prefix assets/
mix assets.deploy
MIX_ENV=prod mix release
bin/deploy-release
bin/deploy-restart

systemctl status orb-showcase.service
```

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
