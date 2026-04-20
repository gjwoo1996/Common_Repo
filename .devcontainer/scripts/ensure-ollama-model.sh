#!/bin/bash
set -e

echo "Checking Ollama..."
until curl -s http://ollama:11434/api/tags > /dev/null 2>&1; do
  sleep 2
done

COMPOSE_PROJECT_NAME="$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')_devcontainer"
TAGS="$(curl -s http://ollama:11434/api/tags)" || true

MODELS=("qwen3:8b" "qwen2.5:7b" "llava:7b")
for MODEL in "${MODELS[@]}"; do
  if echo "$TAGS" | grep -q "$MODEL"; then
    echo "$MODEL already installed"
  else
    echo "Installing $MODEL..."
    docker compose -f .devcontainer/docker-compose.yml -p "$COMPOSE_PROJECT_NAME" exec -T ollama ollama pull "$MODEL"
  fi
done

echo "Model check complete"
