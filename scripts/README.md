# 🛠️ Scripts Directory

이 디렉토리에는 C++ 개발 환경 설치와 관리를 위한 스크립트들이 포함되어 있습니다.

## 📁 디렉토리 구조

```
scripts/
├── cpp_development_environment/     # C++ 개발 환경 설치 스크립트들
│   ├── setup.sh                   # 메인 설치 스크립트
│   ├── verify.sh                  # 설치 검증 스크립트
│   ├── common/                    # 공통 유틸리티와 설정
│   └── linux/                     # Linux 전용 설치 스크립트들
└── format_shell_scripts.sh        # 쉘 스크립트 포매터
```

## 🚀 사용법

### C++ 개발 환경 설치

```bash
# 전체 C++ 개발 환경 설치 (자동으로 OS 감지)
./scripts/cpp_development_environment/setup.sh

# 설치 검증
./scripts/cpp_development_environment/verify.sh
```

### 쉘 스크립트 포매팅

```bash
# 모든 쉘 스크립트 포매팅
./scripts/format_shell_scripts.sh --format

# 포매팅 검사 (변경 없이 확인만)
./scripts/format_shell_scripts.sh --check

# shellcheck 실행
./scripts/format_shell_scripts.sh --shellcheck

# 모든 검사 실행 (포매팅 + 검증 + shellcheck)
./scripts/format_shell_scripts.sh --all

# 도움말 보기
./scripts/format_shell_scripts.sh --help
```

## 🎯 포매팅 규칙

프로젝트의 모든 쉘 스크립트는 다음 규칙을 따릅니다:

- **들여쓰기**: 2칸 스페이스
- **케이스문 들여쓰기**: 활성화
- **이진 연산자**: 다음 줄에 위치 (`&&`, `||`)
- **함수 여는 브레이스**: 같은 줄에 위치
- **최대 줄 길이**: 120자
- **끝부분 공백**: 제거
- **파일 끝 개행**: 강제

## 🔧 개발 도구 통합

### VS Code 설정

프로젝트에는 `.editorconfig` 파일이 포함되어 있어 VS Code에서 자동으로 포매팅 규칙이 적용됩니다.

권장 확장 프로그램:

- `foxundermoon.shell-format` (쉘 스크립트 포매팅)
- `timonwong.shellcheck` (shellcheck 통합)
- `editorconfig.editorconfig` (EditorConfig 지원)

### Git Hooks (선택사항)

커밋 전 자동 포매팅을 위해 pre-commit hook 설정:

```bash
# .git/hooks/pre-commit 파일 생성
cat << 'EOF' > .git/hooks/pre-commit
#!/bin/bash
./scripts/format_shell_scripts.sh --check
EOF

chmod +x .git/hooks/pre-commit
```

## 🏗️ 아키텍처 특징

### 표준화된 오류 처리

모든 스크립트는 일관된 오류 처리를 사용합니다:

- **표준 오류 코드**: 의미있는 종료 코드 (1=일반, 2=의존성 부족, 3=설치 실패, etc.)
- **handle_error()**: 통합 오류 처리 함수
- **handle_critical_command()**: 중요 명령어 자동 실행 및 오류 처리
- **validate_required_programs()**: 의존성 검증

### 단일 책임 원칙

- **OS 감지**: `detect_os()` 함수
- **사전 검사**: `perform_os_preflight_checks()` 함수
- **설치 워크플로우**: `execute_installation_workflow()` 함수
- **개별 단계 실행**: `execute_installation_step()` 함수

## 🔍 문제 해결

### 포매팅 문제

```bash
# 포매팅 실패 시 백업에서 복원됩니다
# 수동으로 특정 파일만 포매팅
shfmt -i 2 -ci -w path/to/script.sh
```

### shellcheck 문제

```bash
# 특정 파일만 검사
shellcheck path/to/script.sh

# 특정 경고 무시 (스크립트 내에서)
# shellcheck disable=SC2034
unused_variable="value"
```

## 📊 지원하는 도구들

설치되는 C++ 개발 도구들:

### 컴파일러 & 빌드 도구

- **Clang/LLVM**: C++ 컴파일러 및 도구 체인
- **CMake**: 빌드 시스템 생성기
- **Ninja**: 고속 빌드 도구

### 개발 도구

- **Git**: 버전 관리
- **GitHub CLI**: GitHub 통합
- **Visual Studio Code**: IDE (GUI)
- **Fira Code**: 개발용 폰트

### 코드 품질 도구

- **clangd**: LSP 서버 (자동완성, 오류 검사)
- **clang-format**: 코드 포매팅
- **clang-tidy**: 정적 분석
- **lldb**: 디버거

## 🌟 기여 가이드

새로운 설치 스크립트를 추가할 때:

1. **표준화된 오류 처리 사용**
2. **적절한 로깅 함수 사용** (`log_info`, `log_warning`, `log_error`)
3. **shellcheck 통과 확인**
4. **포매팅 규칙 준수**

```bash
# 기여 전 확인 사항
./scripts/format_shell_scripts.sh --all
```
