all: 
	@$(MAKE) docker && \
	$(MAKE) migrate && \
	$(MAKE) install && \
	$(MAKE) serve

docker:
	@docker-compose up -d

migrate:
	@mix ecto.migrate
	
reset:
	@mix ecto.reset
	@$(MAKE) serve

serve:
	@iex -S mix phx.server

install:
	@mix deps.get

push:
	@mix format --check-formatted
	@mix credo --ignore readability
	@mix dialyzer --no-check --ignore-exit-status
	@mix test
	@git add .
	@git commit
	@git push