.PHONY: help build start stop restart logs clean dev prod

help: ## Hiển thị trợ giúp
	@echo "Restaurant Management System - Docker Commands"
	@echo ""
	@echo "Usage: make [command]"
	@echo ""
	@echo "Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

build: ## Build Docker images
	docker-compose build

dev: ## Start development environment (local DB)
	docker-compose up -d --build
	@echo ""
	@echo "✅ Development environment started!"
	@echo "🌐 Access: http://localhost:8080"
	@echo "📊 Logs: make logs"

prod: ## Start production environment (Supabase)
	docker-compose -f docker-compose.supabase.yml up -d --build
	@echo ""
	@echo "✅ Production environment started!"
	@echo "🌐 Access: http://localhost:8080"

start: dev ## Alias for dev

stop: ## Stop all containers
	docker-compose down

restart: ## Restart application
	docker-compose restart webapp

logs: ## View application logs
	docker-compose logs -f webapp

logs-db: ## View database logs
	docker-compose logs -f postgres

ps: ## Show running containers
	docker-compose ps

shell: ## Open shell in webapp container
	docker exec -it restaurant-webapp bash

db-shell: ## Open PostgreSQL shell
	docker exec -it restaurant-db psql -U postgres -d restaurant_db

clean: ## Remove all containers and volumes
	docker-compose down -v
	docker system prune -f

rebuild: clean dev ## Clean and rebuild everything

stats: ## Show container resource usage
	docker stats restaurant-webapp restaurant-db
