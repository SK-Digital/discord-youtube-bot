.PHONY: help build run stop logs clean test lint format

# Default target
help:
	@echo "Discord YouTube Bot - Available commands:"
	@echo "  build     - Build Docker image"
	@echo "  run       - Run bot with Docker Compose"
	@echo "  stop      - Stop bot"
	@echo "  logs      - Show logs"
	@echo "  clean     - Clean up containers and images"
	@echo "  test      - Run tests"
	@echo "  lint      - Run linting"
	@echo "  format    - Format code"
	@echo "  dev       - Run locally for development"

# Build Docker image
build:
	docker build -t discord-youtube-bot .

# Run with Docker Compose
run:
	docker-compose up -d

# Stop the bot
stop:
	docker-compose down

# Show logs
logs:
	docker-compose logs -f

# Clean up
clean:
	docker-compose down -v
	docker system prune -f

# Run tests
test:
	python -m pytest tests/ -v

# Run linting
lint:
	flake8 bot.py
	black --check bot.py

# Format code
format:
	black bot.py
	isort bot.py

# Development setup
dev:
	python -m venv venv
	source venv/bin/activate && pip install -r requirements.txt
	cp .env.example .env
	@echo "Development environment setup complete!"
	@echo "Edit .env with your Discord bot token and run: source venv/bin/activate && python bot.py"

# Production deployment
deploy: build run
	@echo "Bot deployed to production!"

# Update dependencies
update:
	pip-compile requirements.in
	docker-compose build --no-cache
