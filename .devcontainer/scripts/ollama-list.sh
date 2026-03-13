#!/bin/bash
# 설치된 Ollama 모델 목록 출력 (컨테이너 내부에서 실행 시 API, 실패 시 exec 폴백)

set -e
COMPOSE_FILE="${BASH_SOURCE%/*}/../docker-compose.yml"
PROJECT_NAME="common_repo_devcontainer"

if TAGS=$(curl -s http://ollama:11434/api/tags 2>/dev/null); then
  if command -v jq &>/dev/null; then
    echo "$TAGS" | jq -r '.models[]? | "\(.name)  \(.details.parameter_size // "")  \(.size // 0 | . / 1024 / 1024 / 1024 | tostring + " GB")"' 2>/dev/null || echo "$TAGS"
  else
    echo "$TAGS"
  fi
else
  docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" exec -T ollama ollama list
fi
