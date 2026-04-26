# Ollama(LLM) 명령어 정리

Common_Repo devcontainer에서 Ollama 서비스 상태 확인, 모델 테스트, 로그 확인에 사용하는 명령어입니다.

**프로젝트 이름**: Docker Compose 사용 시 `-p common_repo_devcontainer` (소문자)를 사용합니다.

---

## 1. 동작 확인

### 모델 목록 조회

**컨테이너 내부(workspace)에서:**

```bash
curl -s http://ollama:11434/api/tags
```

**호스트에서 (포트 11434 포워딩된 경우):**

```bash
curl -s http://localhost:11434/api/tags
```

**CLI로 모델 목록:**

```bash
docker compose -f .devcontainer/docker-compose.yml -p common_repo_devcontainer exec ollama ollama list
```

---

## 2. 자연어로 모델에 보내서 응답 받기 테스트

자동 설치 모델: `qwen3:8b`, `qwen2.5:7b`, `qwen2.5vl:7b`

- 일본어 학습 어시스트 기본 추천: `qwen3:8b`
- 안정적 백업 모델: `qwen2.5:7b`
- 이미지 입력 + 일본어 분석용 (비전 멀티모달): `qwen2.5vl:7b`

### API (컨테이너 내부)

```bash
# qwen3:8b (기본, 일본어 학습 추천)
curl -s http://ollama:11434/api/generate -d '{"model":"qwen3:8b","prompt":"한 줄로 인사해줘.","stream":false}'

# qwen2.5:7b
curl -s http://ollama:11434/api/generate -d '{"model":"qwen2.5:7b","prompt":"한 줄로 인사해줘.","stream":false}'

# qwen2.5vl:7b (텍스트)
curl -s http://ollama:11434/api/generate -d '{"model":"qwen2.5vl:7b","prompt":"한 줄로 인사해줘.","stream":false}'

# qwen2.5vl:7b (이미지 + 일본어 분석 — base64 이미지 포함)
curl -s http://ollama:11434/api/generate -d '{
  "model": "qwen2.5vl:7b",
  "prompt": "이 일본어 지문을 한 줄씩 분석해줘. 각 줄마다: 원문, 후리가나, 한국어 해석, 주요 단어를 알려줘.",
  "images": ["<BASE64_ENCODED_IMAGE>"],
  "stream": false
}'
```

응답 JSON의 `response` 필드에 모델 출력이 담깁니다.

### API (호스트에서)

위 명령에서 URL만 `http://localhost:11434` 로 바꿉니다.

```bash
curl -s http://localhost:11434/api/generate -d '{"model":"qwen3:8b","prompt":"한 줄로 인사해줘.","stream":false}'
```

### CLI (exec)

프롬프트를 바꿔가며 자연어 테스트할 수 있습니다.

```bash
# qwen3:8b
docker compose -f .devcontainer/docker-compose.yml -p common_repo_devcontainer exec -T ollama ollama run qwen3:8b "한 줄로 인사해줘."

# qwen2.5:7b
docker compose -f .devcontainer/docker-compose.yml -p common_repo_devcontainer exec -T ollama ollama run qwen2.5:7b "한 줄로 인사해줘."

# qwen2.5vl:7b
docker compose -f .devcontainer/docker-compose.yml -p common_repo_devcontainer exec -T ollama ollama run qwen2.5vl:7b "한 줄로 인사해줘."
```

다른 문장으로 테스트할 때는 마지막 인자만 변경하면 됩니다.

---

## 3. 로그 확인

**실시간 로그 (Ctrl+C로 종료):**

```bash
docker compose -f .devcontainer/docker-compose.yml -p common_repo_devcontainer logs -f ollama
```

**최근 N줄만 보기:**

```bash
docker compose -f .devcontainer/docker-compose.yml -p common_repo_devcontainer logs --tail 100 ollama
```

---

## 4. 간소화된 사용법 (스크립트)

워크스페이스 루트(`/workspaces/Common_Repo`)에서 실행합니다.

| 목적           | 명령어 |
|----------------|--------|
| 모델 목록      | `bash .devcontainer/scripts/ollama-list.sh` |
| 자연어 테스트  | `bash .devcontainer/scripts/ollama-test.sh` 또는 `bash .devcontainer/scripts/ollama-test.sh "질문할 문장"` |
| Ollama 로그    | `bash .devcontainer/scripts/ollama-logs.sh` |

### ollama-test.sh 모델 선택

첫 번째 인자가 `:` 포함 모델명이면 해당 모델 사용, 없으면 기본 `qwen3:8b` 사용.

```bash
ollama-test.sh                                      # qwen3:8b, 기본 프롬프트
ollama-test.sh "날씨 어때?"                         # qwen3:8b, "날씨 어때?"
ollama-test.sh qwen3:8b "JLPT N4 문법 설명해줘"    # qwen3:8b, 일본어 학습 테스트
ollama-test.sh qwen2.5:7b "날씨 어때?"              # qwen2.5:7b, "날씨 어때?"
ollama-test.sh qwen2.5vl:7b "이 이미지를 분석해줘" # qwen2.5vl:7b, 비전 모델 테스트
```
