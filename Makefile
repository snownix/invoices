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