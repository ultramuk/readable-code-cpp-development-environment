# 구성 요소별 상세 설명

## 1. utilities.sh 핵심 기능

### 1.1 로깅 시스템

| 함수 | 출력 대상 | 형식 | 용도 |
|------|-----------|------|------|
| `log_info()` | stdout | `[INFO] [타임스탬프] 메시지` | 진행 상황 알림 |
| `log_warning()` | stdout | `[WARNING] [타임스탬프] 메시지` | 경고 상황 알림 |
| `log_error()` | stderr | `[ERROR] [타임스탬프] 메시지` | 오류 상황 알림 |

### 1.2 오류 처리 시스템

#### 표준화된 종료 코드

```bash
ERROR_GENERAL=1                 # 일반적인 오류
ERROR_DEPENDENCY_MISSING=2      # 의존성 누락
ERROR_INSTALLATION_FAILED=3     # 설치 실패
ERROR_VERIFICATION_FAILED=4     # 검증 실패
ERROR_CONFIGURATION_FAILED=5    # 설정 실패
ERROR_PERMISSION_DENIED=6       # 권한 거부
```

#### 핵심 오류 처리 함수

| 함수 | 매개변수 | 동작 |
|------|----------|------|
| `handle_error()` | error_code, message, cleanup_function | 오류 로그 출력 → 정리 함수 실행 → 종료 |
| `handle_critical_command()` | command, message, cleanup_function | 명령어 실행 → 실패 시 handle_error 호출 |
| `validate_required_programs()` | program_list | 여러 프로그램 존재 여부 일괄 검증 |

### 1.3 OS 감지 및 검증

#### OS 감지 로직

1. `OSTYPE` 환경변수 확인
2. `uname` 명령어 결과 확인
3. `DETECTED_OPERATING_SYSTEM` 변수에 "macos" 또는 "linux" 설정
4. 지원되지 않는 OS인 경우 오류 처리

#### 사전 검사 (Preflight Checks)

| 플랫폼 | 확인 항목 | 실패 시 동작 |
|--------|-----------|-------------|
| macOS | Homebrew 설치 여부 | ERROR_DEPENDENCY_MISSING로 종료 |
| Linux | sudo 권한, apt-get 존재 | ERROR_PERMISSION_DENIED 또는 ERROR_DEPENDENCY_MISSING로 종료 |

### 1.4 설치 워크플로우 관리

#### 설치 단계 순서 (9단계)

```text
1. install_clang.sh         # Clang/LLVM 컴파일러
2. install_cmake.sh         # CMake 빌드 시스템
3. install_ninja.sh         # Ninja 빌드 도구
4. install_git.sh           # Git 버전 관리
5. install_github_cli.sh    # GitHub CLI
6. install_coding_font.sh   # Fira Code 폰트
7. install_vscode.sh        # Visual Studio Code
8. configure_vscode.sh      # VS Code 설정
9. setup_sample_project.sh  # 샘플 프로젝트 생성
```

#### 워크플로우 실행 함수

| 함수 | 역할 | 실패 처리 |
|------|------|----------|
| `get_installation_steps()` | OS별 설치 스크립트 목록 반환 | - |
| `execute_installation_step()` | 개별 단계 실행 및 로깅 | 스크립트 실행 실패 시 오류 처리 |
| `execute_installation_workflow()` | 전체 워크플로우 순차 실행 | 단계별 실패 시 전체 프로세스 중단 |

### 1.5 프로그램 검증 시스템

| 함수 | 검증 방법 | 반환값 |
|------|-----------|--------|
| `is_program_installed()` | `command -v` 명령어로 PATH 확인 | 0 (설치됨) / 1 (설치 안됨) |
| `verify_command()` | 프로그램 실행 및 버전 정보 출력 | 실행 가능 여부 및 버전 정보 |

## 2. OS별 공통 유틸리티 비교

### 2.1 macOS (macos/common_utils.sh)

#### Homebrew 기반 설치 함수

| 함수 | 패키지 유형 | 동작 |
|------|-------------|------|
| `install_with_brew()` | formula/cask 자동 구분 | 설치 상태 확인 → 미설치시 설치 |
| `_install_with_brew()` | 내부 구현 함수 | 실제 brew 명령어 실행 |
| `install_and_verify_tool()` | 검증 포함 설치 | 설치 → 검증 → 실패시 재시도 |

#### 설치 확인 로직

```bash
brew list --formula $package_name > /dev/null 2>&1    # formula 확인
brew list --cask $package_name > /dev/null 2>&1       # cask 확인
```

### 2.2 Linux (linux/common_utils.sh)

#### apt 기반 설치 함수

| 함수 | 역할 | 특징 |
|------|------|------|
| `update_apt_cache()` | 패키지 목록 갱신 | 1회만 실행되도록 플래그 관리 |
| `install_packages()` | 여러 패키지 동시 설치 | 공백으로 구분된 패키지 목록 처리 |
| `install_with_apt()` | 개별 패키지 설치 | 설치 상태 확인 후 설치 |
| `install_and_verify_tool()` | 검증 포함 설치 | 설치 → 검증 → 실패시 재시도 |

#### 설치 확인 로직

```bash
dpkg -l | grep "^ii  $package_name " > /dev/null 2>&1   # 설치 확인
apt-get install -y $package_name                        # 설치 실행
```

## 3. 개별 도구 설치 스크립트

### 3.1 공통 설치 패턴

#### macOS 설치 스크립트 구조

1. **기존 도구 확인**: Apple 기본 제공 도구 (Apple Clang 등) 확인
2. **Homebrew 설치**: `install_with_brew` 함수 호출
3. **심볼릭 링크**: 필요시 `/usr/local/bin` 링크 생성
4. **최종 검증**: `verify_command` 함수로 설치 확인

#### Linux 설치 스크립트 구조

1. **apt 캐시 업데이트**: `update_apt_cache` 함수 호출
2. **패키지 설치**: critical/non-critical 패키지 구분 설치
3. **최종 검증**: `verify_command` 함수로 설치 확인

### 3.2 도구별 설치 세부사항

| 도구 | macOS 패키지 | Linux 패키지 | 특별 처리 |
|------|-------------|--------------|-----------|
| Clang/LLVM | `llvm` | `clang`, `clangd`, `clang-format` | Apple Clang 중복 확인 |
| CMake | `cmake` | `cmake` | 버전 3.16+ 요구 |
| Ninja | `ninja` | `ninja-build` | - |
| Git | `git` | `git` | 기본 설치된 경우 스킵 |
| GitHub CLI | `gh` | `gh` | - |
| VS Code | `visual-studio-code` (cask) | `code` (snap) | 확장 설치는 별도 처리 |
| Fira Code | `font-fira-code` (cask) | `fonts-firacode` | - |

## 4. VS Code 설정 시스템

### 4.1 configure_vscode.sh 구성

#### 확장 설치 로직

```bash
# 기설치 확장 목록 확인
installed_extensions=$(code --list-extensions)

# 필요한 확장 목록 (총 20개)
required_extensions=(
  # C++ Core Development Tools
  "ms-vscode.cpptools"
  "llvm-vs-code-extensions.vscode-clangd"
  "ms-vscode.cmake-tools"
  "vadimcn.vscode-lldb"
  "cschlosser.doxdocgen"
  "josetr.cmake-language-support-vscode"
  # Testing Frameworks
  "matepek.vscode-catch2-test-adapter"
  "fredericbonnet.cmake-test-adapter"
  # Version Control & Collaboration
  "eamodio.gitlens"
  "github.vscode-pull-request-github"
  "mhutchie.git-graph"
  "ms-vsliveshare.vsliveshare"
  # Code Quality & Readability
  "streetsidesoftware.code-spell-checker"
  "shardulm94.trailing-spaces"
  "oderwat.indent-rainbow"
  "usernamehw.errorlens"
  "editorconfig.editorconfig"
  # Other Useful Utilities
  "christian-kohler.path-intellisense"
  "redhat.vscode-yaml"
  "docker.docker"
)

# 확장별 설치 상태 확인 및 설치
for extension in "${required_extensions[@]}"; do
  if ! echo "$installed_extensions" | grep -q "$extension"; then
    code --install-extension "$extension" --force
  fi
done
```

#### 설정 병합 과정

1. **jq 도구 설치**: JSON 파싱 및 병합 도구
2. **기존 설정 읽기**: `~/.config/Code/User/settings.json` (Linux) 또는 해당 macOS 경로
3. **템플릿 병합**: `assets/vscode_settings_template.json`과 기존 설정 병합
4. **안전한 교체**: 임시 파일을 통한 원자적 파일 교체

### 4.2 설정 템플릿 내용

#### C++ 개발 최적화 설정

```json
{
  "editor.formatOnSave": true,
  "files.autoSave": "afterDelay",
  "editor.fontFamily": "'Fira Code', Menlo, Monaco, 'Courier New', monospace",
  "editor.fontLigatures": true,
  "C_Cpp.intelliSenseEngine": "disabled",
  "clangd.detectExtensionConflicts": false,
  "clangd.arguments": [
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu"
  ]
}
```

## 5. 샘플 프로젝트 생성 시스템

### 5.1 setup_sample_project.sh 구성

#### 프로젝트 구조 생성

```text
~/cpp-sample/
├── CMakeLists.txt          # CMake 설정 파일
├── main.cpp                # C++ 소스 코드
└── build/                  # 빌드 디렉터리
    └── hello_world         # 실행 파일
```

#### 자동 빌드 과정

1. **디렉터리 생성**: `~/cpp-sample` 및 하위 디렉터리
2. **소스 코드 생성**: C++17 기반 Hello World 프로그램
3. **CMake 설정**: 현대적 C++ 빌드 설정
4. **빌드 실행**: `cmake` → `ninja` 빌드 체인
5. **실행 테스트**: 생성된 실행 파일 동작 확인

## 서브브랜치 네비게이션

- [01-overview.md](01-overview.md) - 프로젝트 전체 개요
- [02-structure.md](02-structure.md) - 프로젝트 구조 상세 분석
- [04-installation-flow.md](04-installation-flow.md) - 설치 과정 상세 플로우
- [05-verification.md](05-verification.md) - 검증 시스템 상세 설명
- [06-specifications.md](06-specifications.md) - 기술 사양 및 요구사항
- [index.md](index.md) - 서브브랜치 인덱스