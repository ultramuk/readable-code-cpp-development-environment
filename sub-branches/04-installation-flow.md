# 설치 과정 상세 플로우

## 1. 전체 설치 플로우

### 1.1 메인 실행 흐름 (setup.sh)

```mermaid
graph TD
    A[setup.sh 시작] --> B[os_agnostic_utils.sh 로드]
    B --> C[OS 감지]
    C --> D{OS 지원 여부}
    D -->|지원| E[OS별 common_utils.sh 로드]
    D -->|미지원| F[오류 종료]
    E --> G[사전 검사 실행]
    G --> H{사전 검사 통과}
    H -->|통과| I[설치 워크플로우 실행]
    H -->|실패| J[의존성 오류 종료]
    I --> K[설치 완료]
    J --> F
```

### 1.2 설치 단계별 흐름

| 단계 | 스크립트 | 실행 순서 | 실패 시 동작 |
|------|----------|-----------|-------------|
| 1 | `install_clang.sh` | 컴파일러 우선 설치 | 전체 프로세스 중단 |
| 2 | `install_cmake.sh` | 빌드 시스템 설치 | 전체 프로세스 중단 |
| 3 | `install_ninja.sh` | 빌드 도구 설치 | 전체 프로세스 중단 |
| 4 | `install_git.sh` | 버전 관리 설치 | 전체 프로세스 중단 |
| 5 | `install_github_cli.sh` | GitHub CLI 설치 | 전체 프로세스 중단 |
| 6 | `install_coding_font.sh` | 폰트 설치 | 전체 프로세스 중단 |
| 7 | `install_vscode.sh` | 편집기 설치 | 전체 프로세스 중단 |
| 8 | `configure_vscode.sh` | VS Code 설정 | 전체 프로세스 중단 |
| 9 | `setup_sample_project.sh` | 샘플 프로젝트 생성 | 전체 프로세스 중단 |

## 2. OS별 설치 플로우

### 2.1 macOS 설치 플로우

#### 사전 검사

```mermaid
graph TD
    A[macOS 감지] --> B[Homebrew 설치 확인]
    B --> C{Homebrew 존재}
    C -->|예| D[사전 검사 통과]
    C -->|아니오| E[ERROR_DEPENDENCY_MISSING]
    E --> F[프로세스 종료]
```

#### 개별 도구 설치 패턴

```mermaid
graph TD
    A[도구 설치 시작] --> B[Apple 기본 도구 확인]
    B --> C{기본 도구 존재}
    C -->|예| D[기본 도구 사용 결정]
    C -->|아니오| E[Homebrew 설치 필요]
    D --> F{설치 스킵 여부}
    F -->|스킵| G[다음 단계]
    F -->|설치| E
    E --> H[brew list 확인]
    H --> I{이미 설치됨}
    I -->|예| J[설치 스킵]
    I -->|아니오| K[brew install 실행]
    K --> L[설치 검증]
    L --> M{검증 성공}
    M -->|성공| N[설치 완료]
    M -->|실패| O[ERROR_INSTALLATION_FAILED]
    J --> N
    N --> G
    O --> P[프로세스 종료]
```

### 2.2 Linux 설치 플로우

#### 사전 검사

```mermaid
graph TD
    A[Linux 감지] --> B[sudo 권한 확인]
    B --> C{sudo 사용 가능}
    C -->|예| D[apt-get 명령어 확인]
    C -->|아니오| E[ERROR_PERMISSION_DENIED]
    D --> F{apt-get 존재}
    F -->|예| G[사전 검사 통과]
    F -->|아니오| H[ERROR_DEPENDENCY_MISSING]
    E --> I[프로세스 종료]
    H --> I
```

#### 개별 도구 설치 패턴

```mermaid
graph TD
    A[도구 설치 시작] --> B[apt 캐시 업데이트]
    B --> C[dpkg -l 확인]
    C --> D{이미 설치됨}
    D -->|예| E[설치 스킵]
    D -->|아니오| F[apt-get install 실행]
    F --> G[설치 검증]
    G --> H{검증 성공}
    H -->|성공| I[설치 완료]
    H -->|실패| J[ERROR_INSTALLATION_FAILED]
    E --> I
    I --> K[다음 단계]
    J --> L[프로세스 종료]
```

## 3. 개별 도구 설치 세부 플로우

### 3.1 Clang/LLVM 설치 플로우

#### macOS Clang 설치

```mermaid
graph TD
    A[Clang 설치 시작] --> B[Apple Clang 확인]
    B --> C{Apple Clang 존재}
    C -->|예| D[Apple vs LLVM Clang 선택]
    C -->|아니오| E[LLVM Clang 필수 설치]
    D --> F{LLVM Clang 설치 필요}
    F -->|예| E
    F -->|아니오| G[Apple Clang 사용]
    E --> H[brew install llvm]
    H --> I[PATH 확인]
    I --> J[clang 버전 검증]
    J --> K[clangd 검증]
    K --> L[clang-format 검증]
    L --> M{모든 도구 검증 성공}
    M -->|성공| N[설치 완료]
    M -->|실패| O[설치 실패]
    G --> P[Apple Clang 검증]
    P --> Q{Apple Clang 동작}
    Q -->|성공| N
    Q -->|실패| O
```

#### Linux Clang 설치

```mermaid
graph TD
    A[Clang 설치 시작] --> B[apt 캐시 업데이트]
    B --> C[clang 패키지 설치]
    C --> D[clangd 패키지 설치]
    D --> E[clang-format 패키지 설치]
    E --> F[clang-tidy 패키지 설치]
    F --> G[설치 검증]
    G --> H{모든 도구 검증 성공}
    H -->|성공| I[설치 완료]
    H -->|실패| J[설치 실패]
```

### 3.2 VS Code 설정 플로우

```mermaid
graph TD
    A[VS Code 설정 시작] --> B[jq 도구 설치]
    B --> C[기설치 확장 목록 조회]
    C --> D[필요한 확장 목록과 비교]
    D --> E{미설치 확장 존재}
    E -->|예| F[확장 설치 루프]
    E -->|아니오| G[설정 파일 처리]
    F --> H[code --install-extension 실행]
    H --> I{설치 성공}
    I -->|성공| J{더 많은 확장}
    I -->|실패| K[확장 설치 실패]
    J -->|예| F
    J -->|아니오| G
    G --> L[기존 settings.json 읽기]
    L --> M[템플릿과 병합]
    M --> N[임시 파일 생성]
    N --> O[설정 파일 교체]
    O --> P{교체 성공}
    P -->|성공| Q[설정 완료]
    P -->|실패| R[설정 실패]
    K --> R
```

### 3.3 샘플 프로젝트 생성 플로우

```mermaid
graph TD
    A[샘플 프로젝트 생성 시작] --> B[~/cpp-sample 디렉터리 생성]
    B --> C[CMakeLists.txt 생성]
    C --> D[main.cpp 소스 파일 생성]
    D --> E[build 디렉터리 생성]
    E --> F[cmake 설정 실행]
    F --> G{cmake 성공}
    G -->|성공| H[ninja 빌드 실행]
    G -->|실패| I[빌드 설정 실패]
    H --> J{ninja 빌드 성공}
    J -->|성공| K[실행 파일 테스트]
    J -->|실패| L[빌드 실패]
    K --> M{실행 파일 동작}
    M -->|성공| N[샘플 프로젝트 완료]
    M -->|실패| O[실행 파일 오류]
    I --> P[프로젝트 생성 실패]
    L --> P
    O --> P
```

## 4. 오류 처리 플로우

### 4.1 표준 오류 처리

```mermaid
graph TD
    A[오류 발생] --> B[handle_error 호출]
    B --> C[오류 메시지 로그 출력]
    C --> D{정리 함수 존재}
    D -->|예| E[정리 함수 실행]
    D -->|아니오| F[프로세스 종료]
    E --> G{정리 함수 성공}
    G -->|성공| F
    G -->|실패| H[정리 실패 로그]
    H --> F
```

### 4.2 중요 명령어 실행 플로우

```mermaid
graph TD
    A[handle_critical_command 호출] --> B[명령어 실행]
    B --> C{명령어 성공}
    C -->|성공| D[성공 로그 출력]
    C -->|실패| E[handle_error 호출]
    D --> F[다음 단계 진행]
    E --> G[오류 처리 플로우]
    G --> H[프로세스 종료]
```

## 5. 검증 플로우 (verify.sh)

### 5.1 전체 검증 플로우

```mermaid
graph TD
    A[verify.sh 시작] --> B[설치된 도구 목록 정의]
    B --> C[도구별 검증 루프]
    C --> D[is_program_installed 확인]
    D --> E{PATH에 존재}
    E -->|예| F[verify_command 실행]
    E -->|아니오| G[도구 누락 기록]
    F --> H{버전 정보 확인 성공}
    H -->|성공| I[검증 성공 기록]
    H -->|실패| J[검증 실패 기록]
    I --> K{더 많은 도구}
    J --> K
    G --> K
    K -->|예| C
    K -->|아니오| L[검증 결과 요약]
    L --> M{모든 도구 검증 성공}
    M -->|성공| N[전체 검증 성공]
    M -->|실패| O[일부 도구 검증 실패]
```

### 5.2 개별 도구 검증 세부사항

| 도구 | 검증 명령어 | 성공 조건 | 실패 시 메시지 |
|------|------------|----------|---------------|
| clang | `clang --version` | 버전 정보 출력 | "Clang compiler not found or not working" |
| clangd | `clangd --version` | 버전 정보 출력 | "clangd language server not found" |
| clang-tidy | `clang-tidy --version` | 버전 정보 출력 | "clang-tidy static analyzer not found" |
| clang-format | `clang-format --version` | 버전 정보 출력 | "clang-format code formatter not found" |
| lldb | `lldb --version` | 버전 정보 출력 | "LLDB debugger not found" |
| cmake | `cmake --version` | 버전 3.16+ | "CMake not found or version too old" |
| ninja | `ninja --version` | 버전 정보 출력 | "Ninja build tool not found" |
| git | `git --version` | 버전 정보 출력 | "Git version control not found" |
| gh | `gh --version` | 버전 정보 출력 | "GitHub CLI not found" |

## 서브브랜치 네비게이션

- [01-overview.md](01-overview.md) - 프로젝트 전체 개요
- [02-structure.md](02-structure.md) - 프로젝트 구조 상세 분석
- [03-components.md](03-components.md) - 구성 요소별 상세 설명
- [05-verification.md](05-verification.md) - 검증 시스템 상세 설명
- [06-specifications.md](06-specifications.md) - 기술 사양 및 요구사항
- [index.md](index.md) - 서브브랜치 인덱스