#!/bin/bash
# 자연어 프롬프트를 모델에 보내 응답을 받는 테스트 (인자 없으면 기본 문장 사용)

PROMPT="${*:-한 줄로 인사해줘.}"
if command -v jq &>/dev/null; then
  PAYLOAD=$(jq -n --arg prompt "$PROMPT" '{model: "qwen2.5:7b", prompt: $prompt, stream: false}')
else
  PAYLOAD="{\"model\":\"qwen2.5:7b\",\"prompt\":\"$PROMPT\",\"stream\":false}"
fi
RESPONSE=$(curl -s http://ollama:11434/api/generate -d "$PAYLOAD")

if command -v jq &>/dev/null; then
  echo "$RESPONSE" | jq -r '.response // .message // .'
else
  echo "$RESPONSE" | sed -n 's/.*"response":"\([^"]*\)".*/\1/p' || echo "$RESPONSE"
fi
