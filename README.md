# OrbShowcase

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:8344`](http://localhost:8344) from your browser.

## Production deploy

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

```bash
cd /root
micro Caddyfile
caddy fmt --overwrite
caddy reload

cd /var/www/orb_showcase

MIX_ENV=prod mix systemd.generate
MIX_ENV=prod mix deploy.generate

micro config/environment
bin/deploy-copy-files

MIX_ENV=prod mix release
mix assets.deploy
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
