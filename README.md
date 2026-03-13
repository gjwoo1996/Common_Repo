# Common_Repo

공통 개발 서비스(LLM, PostgreSQL, CloudBeaver)를 제공하는 devcontainer 스택입니다.  
다른 프로젝트의 devcontainer에서 이 스택의 서비스를 `host.docker.internal`로 접속해 사용할 수 있습니다.

## 제공 서비스

| 서비스       | 포트  | 설명                    |
|-------------|-------|-------------------------|
| Ollama      | 11434 | LLM 로컬 서버           |
| PostgreSQL  | 5432  | 공통 DB                 |
| CloudBeaver | 8978  | 웹 기반 DB 관리 UI      |

## 실행 방법

1. (선택) PostgreSQL 비밀번호 등 변경 시: 루트에 `.env` 생성  
   - `cp .env.example .env` 후 값 수정  
   - 없으면 기본값 사용 (user/password/db: `postgres`)

2. **Reopen in Container**  
   - VS Code에서 이 폴더(Common_Repo)를 연 뒤  
   - 명령 팔레트 → "Dev Containers: Reopen in Container" 실행

   또는 터미널에서:

   ```bash
   cd Common_Repo
   docker compose -f .devcontainer/docker-compose.yml up -d
   ```

3. 컨테이너가 뜨면 Ollama에 `qwen2.5:7b` 모델이 없을 때만 자동으로 설치됩니다.  
   (이미 있으면 스킵되므로 재시작 시 재설치되지 않습니다.)

## 접속 정보

### 이 스택(Common_Repo) 안에서

- **Ollama**: `http://ollama:11434`
- **PostgreSQL**: 호스트명 `postgres`, 포트 `5432`
- **CloudBeaver**: `http://cloudbeaver:8978` (같은 네트워크) 또는 호스트 브라우저에서 `http://localhost:8978`

### 다른 devcontainer에서 (host.docker.internal)

Common_Repo 스택을 먼저 띄운 뒤, 다른 프로젝트 devcontainer에서 아래처럼 접속합니다.

- **Ollama**: `OLLAMA_HOST=http://host.docker.internal:11434`
- **PostgreSQL**: `host.docker.internal:5432` (user/password는 `.env` 또는 기본값)
- **CloudBeaver**: 호스트 브라우저에서 `http://localhost:8978` (다른 컨테이너에서 API로 쓸 일은 거의 없음)

예: 다른 프로젝트의 `docker-compose.yml` 또는 `devcontainer.json`에  
`OLLAMA_HOST=http://host.docker.internal:11434` 를 환경 변수로 설정하면 됩니다.

## 추가 Ollama 모델

컨테이너 안에서:

```bash
docker compose -f .devcontainer/docker-compose.yml -p common_repo_devcontainer exec ollama ollama pull <모델명>
```

예: `ollama pull llama3.2`

## Ollama 참고

### 공식 문서

- **API 문서 (Generate 등)**: https://docs.ollama.com/api/generate  
- **문서 인덱스**: https://docs.ollama.com/

### Generate API 응답 필드 (`/api/generate`)

| 필드 | 설명 |
|------|------|
| `model` | 사용한 모델 이름 |
| `created_at` | 응답 생성 시각 (ISO 8601, UTC) |
| `response` | 모델이 생성한 자연어 답변 텍스트 |
| `done` | 생성 완료 여부 (`true` = 완료) |
| `done_reason` | 생성 종료 사유 (예: `stop` = 정상 종료) |
| `context` | 대화 이어가기용. 다음 요청의 `context`에 그대로 넣으면 이전 대화를 기억함 |
| `total_duration` | 전체 소요 시간 (나노초) |
| `load_duration` | 모델 로딩에 걸린 시간 (나노초) |
| `prompt_eval_count` | 프롬프트 토큰 수 |
| `prompt_eval_duration` | 프롬프트 평가 시간 (나노초) |
| `eval_count` | 생성된 출력 토큰 수 |
| `eval_duration` | 답변 생성에 걸린 시간 (나노초) |

자세한 명령어·스크립트 사용법은 [doc/ollama-commands.md](doc/ollama-commands.md)를 참고하세요.

## 요구 사항

- Docker (및 Docker Compose)
- Ollama GPU 사용 시: NVIDIA Container Toolkit (`runtime: nvidia` 사용 중)
