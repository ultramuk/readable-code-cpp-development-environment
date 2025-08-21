# 기술 사양

## 지원 플랫폼

| 플랫폼 | 버전 | 패키지 매니저 |
|--------|------|---------------|
| macOS | Sonoma (14.0) 이상 | Homebrew |
| Linux | Ubuntu 22.04 LTS 이상 | apt |

## 설치되는 도구

### Clang/LLVM 도구체인

| 도구 | 용도 |
|------|------|
| clang | C/C++ 컴파일러 |
| clangd | 언어 서버 프로토콜 |
| clang-format | 코드 포매터 |
| clang-tidy | 정적 분석 도구 |
| lldb | 디버거 |

### 빌드 도구

| 도구 | 용도 |
|------|------|
| CMake | 빌드 시스템 생성기 |
| Ninja | 빌드 실행 도구 |

### 개발 도구

| 도구 | 용도 |
|------|------|
| Git | 버전 관리 |
| GitHub CLI | GitHub 연동 |
| Visual Studio Code | 코드 편집기 |
| Fira Code | 프로그래밍 폰트 |

## VS Code 확장 (20개)

### 필수 확장

- llvm-vs-code-extensions.vscode-clangd

### 추가 확장

- formulahendry.code-runner
- ms-vscode.cmake-tools
- twxs.cmake
- cschlosser.doxdocgen
- Jeff-Hykin.better-cpp-syntax
- ms-vsliveshare.vsliveshare
- vadimcn.vscode-lldb
- matepek.vscode-catch2-test-adapter
- fredericbonnet.cmake-test-adapter
- eamodio.gitlens
- donjayamanne.githistory
- mhutchie.git-graph
- GitHub.vscode-pull-request-github
- streetsidesoftware.code-spell-checker
- shardulm94.trailing-spaces
- oderwat.indent-rainbow
- usernamehw.errorlens
- aaron-bond.better-comments
- kohler.path-autocomplete

## 오류 코드

| 코드 | 값 | 의미 |
|------|----|----|
| ERROR_GENERAL | 1 | 일반 오류 |
| ERROR_DEPENDENCY_MISSING | 2 | 의존성 누락 |
| ERROR_INSTALLATION_FAILED | 3 | 설치 실패 |
| ERROR_VERIFICATION_FAILED | 4 | 검증 실패 |
| ERROR_CONFIGURATION_FAILED | 5 | 설정 실패 |
| ERROR_PERMISSION_DENIED | 6 | 권한 거부 |

## 서브브랜치 네비게이션

- [01-overview.md](01-overview.md) - 프로젝트 전체 개요
- [02-structure.md](02-structure.md) - 프로젝트 구조 상세 분석
- [03-components.md](03-components.md) - 구성 요소별 상세 설명
- [04-installation-flow.md](04-installation-flow.md) - 설치 과정 상세 플로우
- [05-verification.md](05-verification.md) - 검증 시스템 상세 설명
- [index.md](index.md) - 서브브랜치 인덱스
