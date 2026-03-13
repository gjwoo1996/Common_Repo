#!/bin/bash
# Ollama 컨테이너 로그 실시간 출력 (--tail N 옵션 지원)

COMPOSE_FILE="${BASH_SOURCE%/*}/../docker-compose.yml"
PROJECT_NAME="common_repo_devcontainer"

if [[ "${1:-}" == "--tail" && -n "${2:-}" ]]; then
  docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" logs --tail "$2" ollama
else
  docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" logs -f ollama
fi
