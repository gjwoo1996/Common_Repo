#!/bin/bash
# 자연어 프롬프트를 모델에 보내 응답을 받는 테스트
# 사용법: ollama-test.sh [모델명] [프롬프트]
#   - 첫 인자가 : 포함 모델명(예: qwen3:8b, qwen2.5:7b, llava:7b)이면 해당 모델 사용
#   - 기본 모델: qwen3:8b, 기본 프롬프트: 한 줄로 인사해줘.

if [[ "$1" == *:* ]]; then
  MODEL="$1"
  shift
else
  MODEL="qwen3:8b"
fi
PROMPT="${*:-한 줄로 인사해줘.}"

if command -v jq &>/dev/null; then
  PAYLOAD=$(jq -n --arg model "$MODEL" --arg prompt "$PROMPT" '{model: $model, prompt: $prompt, stream: false}')
else
  PAYLOAD="{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"stream\":false}"
fi
RESPONSE=$(curl -s http://ollama:11434/api/generate -d "$PAYLOAD")

if command -v jq &>/dev/null; then
  echo "$RESPONSE" | jq -r '.response // .message // .'
else
  echo "$RESPONSE" | sed -n 's/.*"response":"\([^"]*\)".*/\1/p' || echo "$RESPONSE"
fi
