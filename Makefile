deploy:
	mix deps.get
	npm ci --prefix assets/
	mix assets.deploy
	MIX_ENV=prod mix release
	bin/deploy-release
	bin/deploy-restart
