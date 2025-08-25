# 프로젝트 구조 상세 분석

## 1. 스크립트 계층 구조

### 1.1 메인 디렉터리 (`scripts/cpp_development_environment/`)

```text
scripts/cpp_development_environment/
├── setup.sh                           # 메인 진입점
├── verify.sh                          # 설치 검증
├── common/                            # 공통 스크립트
│   ├── utilities.sh                   # 핵심 유틸리티 함수
│   ├── configure_vscode.sh            # VS Code 설정 자동화
│   └── setup_sample_project.sh        # 샘플 프로젝트 생성
└── linux/                             # Linux 전용 설치 스크립트
    └── install_*.sh                   # 개별 도구 설치 스크립트 (7개)
```

### 1.2 개별 도구 설치 스크립트

| 도구 | Linux 스크립트 | 설치 방법 |
|------|----------------|----------------|-----------|
| Clang/LLVM | `install_clang.sh` | brew/apt |
| CMake | `install_cmake.sh` | brew/apt |
| Ninja | `install_ninja.sh` | brew/apt |
| Git | `install_git.sh` | brew/apt |
| GitHub CLI | `install_github_cli.sh` | brew/apt |
| Fira Code | `install_coding_font.sh` | brew cask/apt |
| VS Code | `install_vscode.sh` | brew cask/snap |

## 2. 디렉터리별 역할

### 2.1 common/ 디렉터리

#### utilities.sh
- 오류 처리 함수 (`handle_error`, `handle_critical_command`)
- 로깅 함수 (`log_info`, `log_warning`, `log_error`)
- 설치 워크플로우 실행 함수

#### configure_vscode.sh
- VS Code 설정 템플릿 적용
- C++ 확장 프로그램 설치 (`llvm-vs-code-extensions.vscode-clangd`)
- 사용자 설정 파일 생성 (`~/.config/Code/User/settings.json`)

#### setup_sample_project.sh
- `~/cpp-sample` 디렉터리 생성
- CMakeLists.txt 파일 생성
- main.cpp 소스 파일 생성
- 프로젝트 빌드 실행

### 2.2 linux/ 디렉터리

#### common_utils.sh
- apt 패키지 매니저 업데이트
- apt 명령어 래퍼 함수
- Linux 배포판 정보 수집

#### 개별 설치 스크립트
- apt를 통한 패키지 설치
- sudo 권한 확인
- 설치 성공 여부 검증

## 3. 설정 파일 구조

### 3.1 assets/ 디렉터리

#### vscode_settings_template.json
```json
{
  "editor.formatOnSave": true,
  "files.autoSave": "afterDelay",
  "editor.fontFamily": "'Fira Code', Menlo, Monaco, 'Courier New', monospace",
  "editor.fontLigatures": true,
  "C_Cpp.intelliSenseEngine": "disabled",
  "clangd.detectExtensionConflicts": false,
  "clangd.arguments": ["--background-index", "--clang-tidy"]
}
```

### 3.2 CI/CD 설정

#### .github/workflows/ci.yml
- Linux 매트릭스 빌드
- setup.sh 스크립트 실행
- verify.sh 검증 실행
- 설치된 도구들의 버전 확인

## 4. 파일 명명 규칙

### 4.1 스크립트 명명 패턴

| 패턴 | 용도 | 예시 |
|------|------|------|
| `setup.sh` | 메인 진입점 | 전체 설치 프로세스 시작 |
| `verify.sh` | 검증 스크립트 | 설치 완료 후 확인 |
| `common_utils.sh` | 공통 유틸리티 | 패키지 매니저 래퍼 |
| `install_*.sh` | 개별 도구 설치 | `install_clang.sh`, `install_cmake.sh` |
| `configure_*.sh` | 설정 작업 | `configure_vscode.sh` |
| `setup_*.sh` | 초기 구성 | `setup_sample_project.sh` |

### 4.2 함수 명명 패턴

| 패턴 | 용도 | 예시 |
|------|------|------|
| `handle_*` | 처리 함수 | `handle_error`, `handle_critical_command` |
| `log_*` | 로깅 함수 | `log_info`, `log_warning`, `log_error` |
| `install_*` | 설치 함수 | `install_with_brew`, `install_with_apt` |
| `verify_*` | 검증 함수 | `verify_tool_installation` |

## 5. 의존성 관계

### 5.1 스크립트 의존성 체인

```text
setup.sh
├── common/utilities.sh (source)
├── common/configure_vscode.sh (실행)
└── common/setup_sample_project.sh (실행)
```

### 5.2 외부 의존성

| 플랫폼 | 필수 의존성 | 선택적 의존성 |
|--------|-------------|---------------|
| Linux | sudo 권한, apt, 인터넷 연결 | snapd |
| 공통 | Bash 4.0+, curl/wget | - |

## 서브브랜치 네비게이션

- [01-overview.md](01-overview.md) - 프로젝트 전체 개요
- [03-components.md](03-components.md) - 구성 요소별 상세 설명
- [04-installation-flow.md](04-installation-flow.md) - 설치 과정 상세 플로우
- [05-verification.md](05-verification.md) - 검증 시스템 상세 설명
- [06-specifications.md](06-specifications.md) - 기술 사양 및 요구사항
- [index.md](index.md) - 서브브랜치 인덱스