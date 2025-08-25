# 검증 시스템 상세 설명

## 1. 검증 시스템 개요

### 1.1 검증 목적

설치된 모든 C++ 개발 도구가 정상적으로 작동하고 PATH에서 접근 가능한지 확인합니다.

### 1.2 검증 단계

| 단계 | 검증 내용 | 실행 위치 |
|------|-----------|-----------|
| 설치 중 검증 | 각 도구 설치 직후 기본 동작 확인 | 개별 install_*.sh 스크립트 |
| 전체 검증 | 모든 도구의 버전 정보 및 동작 확인 | verify.sh 스크립트 |
| 샘플 프로젝트 검증 | 실제 C++ 프로젝트 빌드 및 실행 | setup_sample_project.sh |

## 2. verify.sh 검증 시스템

### 2.1 검증 대상 도구

```bash
COMMANDS_TO_VERIFY=(
  "clang"
  "clangd"
  "clang-tidy"
  "clang-format"
  "lldb"
  "cmake"
  "ninja"
  "git"
  "gh"
)
```

### 2.2 검증 함수 구조

#### is_program_installed()

```bash
is_program_installed() {
  local program="$1"
  if command -v "$program" > /dev/null 2>&1; then
    return 0  # 설치됨
  else
    return 1  # 설치 안됨
  fi
}
```

#### verify_command()

```bash
verify_command() {
  local command="$1"
  local description="$2"
  if is_program_installed "$command"; then
    log_info "✓ $description"
    $command --version 2>/dev/null || $command -version 2>/dev/null
    return 0
  else
    log_error "✗ $description - NOT FOUND"
    return 1
  fi
}
```

### 2.3 검증 결과 처리

#### 성공 카운터

```bash
# 개별 도구 검증은 verify_essential_tool 함수를 통해 수행
# 실패 시 handle_error로 즉시 종료되므로 별도 카운터 불필요
```

#### 최종 결과 판정

```bash
# 모든 검증 완료 시 성공 메시지 출력
log_info "🎉 All essential tools are installed and verified successfully!"
```

## 3. 도구별 검증 세부사항

### 3.1 Clang/LLVM 도구체인 검증

#### clang 컴파일러

| 검증 항목 | 명령어 | 예상 출력 |
|-----------|--------|----------|
| 설치 확인 | `command -v clang` | `/path/to/clang` |
| 버전 확인 | `clang --version` | `clang version X.X.X` |
| 기본 컴파일 | `echo 'int main(){}' \| clang -x c++ -` | 정상 컴파일 |

#### clangd 언어 서버

| 검증 항목 | 명령어 | 예상 출력 |
|-----------|--------|----------|
| 설치 확인 | `command -v clangd` | `/path/to/clangd` |
| 버전 확인 | `clangd --version` | `clangd version X.X.X` |

#### clang-format 포매터

| 검증 항목 | 명령어 | 예상 출력 |
|-----------|--------|----------|
| 설치 확인 | `command -v clang-format` | `/path/to/clang-format` |
| 버전 확인 | `clang-format --version` | `clang-format version X.X.X` |

#### clang-tidy 정적 분석

| 검증 항목 | 명령어 | 예상 출력 |
|-----------|--------|----------|
| 설치 확인 | `command -v clang-tidy` | `/path/to/clang-tidy` |
| 버전 확인 | `clang-tidy --version` | `LLVM version X.X.X` |

#### lldb 디버거

| 검증 항목 | 명령어 | 예상 출력 |
|-----------|--------|----------|
| 설치 확인 | `command -v lldb` | `/path/to/lldb` |
| 버전 확인 | `lldb --version` | `lldb version X.X.X` |

### 3.2 빌드 시스템 검증

#### CMake 빌드 시스템

| 검증 항목 | 명령어 | 성공 조건 |
|-----------|--------|----------|
| 설치 확인 | `command -v cmake` | PATH에 존재 |
| 버전 확인 | `cmake --version` | 버전 3.16 이상 |
| 제너레이터 확인 | `cmake --help` | Ninja 제너레이터 지원 |

#### Ninja 빌드 도구

| 검증 항목 | 명령어 | 성공 조건 |
|-----------|--------|----------|
| 설치 확인 | `command -v ninja` | PATH에 존재 |
| 버전 확인 | `ninja --version` | 버전 정보 출력 |

### 3.3 개발 도구 검증

#### Git 버전 관리

| 검증 항목 | 명령어 | 성공 조건 |
|-----------|--------|----------|
| 설치 확인 | `command -v git` | PATH에 존재 |
| 버전 확인 | `git --version` | 버전 정보 출력 |
| 설정 확인 | `git config --list` | 기본 설정 존재 |

#### GitHub CLI

| 검증 항목 | 명령어 | 성공 조건 |
|-----------|--------|----------|
| 설치 확인 | `command -v gh` | PATH에 존재 |
| 버전 확인 | `gh --version` | 버전 정보 출력 |

#### Visual Studio Code

| 검증 항목 | 명령어 | 성공 조건 |
|-----------|--------|----------|
| 설치 확인 | `command -v code` | PATH에 존재 |
| 버전 확인 | `code --version` | 버전 정보 출력 |
| 확장 확인 | `code --list-extensions` | 설치된 확장 목록 |

## 4. 샘플 프로젝트 검증

### 4.1 프로젝트 구조 검증

#### 디렉터리 구조 확인

```bash
~/cpp-sample/
├── CMakeLists.txt          # CMake 설정 파일
├── main.cpp                # C++ 소스 파일
└── build/                  # 빌드 디렉터리
    ├── build.ninja         # Ninja 빌드 파일
    ├── CMakeCache.txt      # CMake 캐시
    └── hello_world         # 실행 파일
```

#### 파일 존재 검증

| 파일 | 검증 방법 | 필수 여부 |
|------|-----------|-----------|
| `~/cpp-sample/CMakeLists.txt` | `test -f` | 필수 |
| `~/cpp-sample/main.cpp` | `test -f` | 필수 |
| `~/cpp-sample/build/hello_world` | `test -x` | 필수 |

### 4.2 빌드 과정 검증

#### CMake 설정 검증

```bash
cd ~/cpp-sample
mkdir -p build
cd build
cmake .. -G Ninja
```

| 검증 항목 | 성공 조건 | 실패 시 메시지 |
|-----------|----------|---------------|
| CMake 실행 | 종료 코드 0 | "CMake configuration failed" |
| Ninja 파일 생성 | `build.ninja` 파일 존재 | "Ninja build file not generated" |

#### 빌드 실행 검증

```bash
ninja
```

| 검증 항목 | 성공 조건 | 실패 시 메시지 |
|-----------|----------|---------------|
| 컴파일 성공 | 종료 코드 0 | "Compilation failed" |
| 실행 파일 생성 | `hello_world` 실행 파일 존재 | "Executable not created" |

#### 실행 파일 검증

```bash
./hello_world
```

| 검증 항목 | 성공 조건 | 예상 출력 |
|-----------|----------|----------|
| 프로그램 실행 | 종료 코드 0 | "Hello, Modern C++! y = 84" |

### 4.3 VS Code 설정 검증

#### 설정 파일 확인

| 플랫폼 | 설정 파일 경로 | 검증 방법 |
|--------|----------------|-----------|
| Linux | `~/.config/Code/User/settings.json` | `test -f` |

#### 확장 설치 검증

```bash
code --list-extensions | grep -E "(clangd|ms-vscode)"
```

| 확장 유형 | 개수 | 필수 여부 |
|-----------|------|---------|
| C++ 개발 도구 | 6개 | 필수 |
| 테스트 프레임워크 | 2개 | 권장 |
| 버전 관리 | 4개 | 권장 |
| 코드 품질 | 5개 | 권장 |
| 기타 유틸리티 | 3개 | 선택적 |
| **총 설치 확장** | **20개** | - |

## 5. 오류 진단 및 해결

### 5.1 일반적인 검증 실패 사례

#### PATH 관련 문제

| 증상 | 원인 | 해결 방법 |
|------|------|----------|
| `command not found` | PATH에 도구 경로 누락 | 쉘 재시작 또는 PATH 수동 추가 |
| 잘못된 버전 실행 | 여러 버전 설치로 인한 충돌 | `which` 명령어로 실행 경로 확인 |

#### 권한 관련 문제

| 증상 | 원인 | 해결 방법 |
|------|------|----------|
| `permission denied` | 실행 권한 없음 | `chmod +x` 실행 |
| VS Code 확장 설치 실패 | 사용자 디렉터리 권한 | 권한 확인 및 수정 |

#### 빌드 관련 문제

| 증상 | 원인 | 해결 방법 |
|------|------|----------|
| CMake 설정 실패 | 컴파일러 찾을 수 없음 | `CMAKE_C_COMPILER`, `CMAKE_CXX_COMPILER` 설정 |
| 링크 오류 | 라이브러리 누락 | 필요한 개발 패키지 설치 |

### 5.2 플랫폼별 특이사항

#### Linux 특이사항

| 문제 | 원인 | 해결 방법 |
|------|------|----------|
| snap 앱 PATH | snap 설치 앱이 PATH에 없음 | `/snap/bin` PATH 추가 |
| 라이브러리 버전 충돌 | 시스템 패키지와 충돌 | `apt list --installed` 확인 |

## 6. 검증 결과 해석

### 6.1 성공 메시지

```bash
[INFO] 🎉 All essential tools are installed and verified successfully!
```

### 6.2 실패 메시지

```bash
[ERROR] 💀 Fatal error: 'clang-tidy' is not installed or not in PATH. Please run the setup script.
[INFO] 🧹 Running cleanup: cleanup_function
[ERROR] 💀 Fatal error: 'code' command not found in PATH. Skipping VS Code extension installation.
```

### 6.3 부분 성공 처리

일부 도구가 실패해도 핵심 도구 (clang, cmake, ninja)가 성공하면 기본 개발은 가능합니다.

| 필수 도구 | 선택적 도구 | 영향 |
|-----------|-------------|------|
| clang, cmake, ninja | git, gh, lldb | 기본 빌드 가능 |
| clang, cmake | clang-format, clang-tidy | 코드 품질 도구 없음 |

## 서브브랜치 네비게이션

- [01-overview.md](01-overview.md) - 프로젝트 전체 개요
- [02-structure.md](02-structure.md) - 프로젝트 구조 상세 분석
- [03-components.md](03-components.md) - 구성 요소별 상세 설명
- [04-installation-flow.md](04-installation-flow.md) - 설치 과정 상세 플로우
- [06-specifications.md](06-specifications.md) - 기술 사양 및 요구사항
- [index.md](index.md) - 서브브랜치 인덱스
