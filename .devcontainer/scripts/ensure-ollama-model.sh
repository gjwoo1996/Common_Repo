#!/bin/bash
set -e

echo "Checking Ollama..."
until curl -s http://ollama:11434/api/tags > /dev/null 2>&1; do
  sleep 2
done

COMPOSE_PROJECT_NAME="$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')_devcontainer"
TAGS="$(curl -s http://ollama:11434/api/tags)" || true

if echo "$TAGS" | grep -q 'qwen2.5:7b'; then
  echo "qwen2.5:7b already installed"
else
  echo "Installing qwen2.5:7b..."
  docker compose -f .devcontainer/docker-compose.yml -p "$COMPOSE_PROJECT_NAME" exec -T ollama ollama pull qwen2.5:7b
fi

echo "Model check complete"
