.PHONY: deploy stop logs

deploy:
	bash deploy-digitalocean.sh

stop:
	docker-compose -f docker-compose.supabase.yml down

logs:
	docker-compose -f docker-compose.supabase.yml logs -f
