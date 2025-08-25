# C++ 개발 환경 자동 설정 도구 Overview

## 프로젝트 정의

C++ 개발에 필요한 모든 도구를 자동으로 설치하고 구성하는 Shell 스크립트 기반 도구입니다. 단일 명령어로 Linux에서 완전한 C++ 개발 환경을 구축합니다.

## 프루트 (결과물)

- **형태**: 완전히 구성된 C++ 개발 환경 + 실행 가능한 샘플 프로젝트
- **핵심 기능**:
  - 플랫폼별 도구 설치
  - 개발 도구 일괄 설치 (Clang/LLVM, CMake, Ninja, Git, GitHub CLI, VS Code)
  - VS Code C++ 개발 환경 자동 설정 및 확장 설치
  - 샘플 프로젝트 생성, 빌드 및 실행
  - 설치 검증 및 확인
- **사용 방법**: `cd scripts/cpp_development_environment && bash setup.sh`
- **결과물 위치**:
  - 시스템 전체: PATH에 등록된 개발 도구들
  - `~/cpp-sample`: 빌드된 Hello World C++ 프로젝트
  - VS Code 사용자 설정: Linux `~/.config/Code/User/settings.json`

## 전체 구조

```text
scripts/cpp_development_environment/
├── setup.sh                    # 메인 진입점 스크립트
├── verify.sh                   # 설치 검증 스크립트
├── common/                     # 공통 스크립트
│   ├── utilities.sh            # 핵심 유틸리티 함수
│   ├── configure_vscode.sh     # VS Code 설정
│   └── setup_sample_project.sh # 샘플 프로젝트 생성
└── linux/                      # Linux 전용 설치 스크립트
    └── install_*.sh            # 개별 도구 설치 스크립트
```

## 주요 구성 요소

### 1. 진입점 스크립트

- **setup.sh**: 사전 검사, 설치 워크플로우 실행
- **verify.sh**: 설치된 도구들의 버전 확인 및 동작 테스트

### 2. 공통 유틸리티 (common/)

- **utilities.sh**: 오류 처리, 로깅 함수
- **configure_vscode.sh**: VS Code 설정 파일 생성 및 확장 설치
- **setup_sample_project.sh**: C++ 샘플 프로젝트 생성 및 빌드

### 3. 플랫폼별 설치 스크립트

- **linux/**: apt 패키지 매니저 기반 도구 설치

## 기술 스택 / 도구

### 설치 도구

- **컴파일러**: Clang/LLVM 도구 체인
- **빌드 시스템**: CMake, Ninja
- **버전 관리**: Git, GitHub CLI
- **편집기**: Visual Studio Code + clangd 확장
- **폰트**: Fira Code (프로그래밍 리거처 폰트)

### 스크립트 기술

- **Shell**: Bash 스크립트
- **패키지 매니저**: apt (Linux)
- **설정 포맷**: JSON (VS Code 설정)

## 의존성 / 연결 관계

### 외부 의존성

- **Linux**: sudo 권한, apt 패키지 매니저
- **공통**: 인터넷 연결

### 내부 관계

```text
setup.sh → utilities.sh (OS 감지)
        → linux/common_utils.sh
        → 개별 install_*.sh 스크립트들
        → configure_vscode.sh
        → setup_sample_project.sh
```

### 데이터 흐름

1. OS 감지 및 환경 변수 설정
2. 플랫폼별 도구 순차 설치
3. VS Code 설정 파일 생성
4. 샘플 프로젝트 생성 및 빌드
5. 설치 완료 확인

## 핵심 파일/폴더

| 파일/폴더 | 역할 | 위치 | 실행 방식 |
|-----------|------|------|-----------|
| `setup.sh` | 메인 진입점 | `scripts/cpp_development_environment/` | `bash setup.sh` |
| `verify.sh` | 설치 검증 | `scripts/cpp_development_environment/` | `bash verify.sh` |
| `utilities.sh` | 공통 유틸리티 | `scripts/cpp_development_environment/common/` | source로 로드 |
| `configure_vscode.sh` | VS Code 설정 | `scripts/cpp_development_environment/common/` | setup.sh에서 호출 |
| `setup_sample_project.sh` | 샘플 프로젝트 | `scripts/cpp_development_environment/common/` | setup.sh에서 호출 |
| `install_*.sh` | 개별 도구 설치 | `scripts/cpp_development_environment/linux/` | setup.sh에서 호출 |
| `vscode_settings_template.json` | VS Code 설정 템플릿 | `assets/` | configure_vscode.sh에서 사용 |

## 서브브랜치 네비게이션

- [02-structure.md](02-structure.md) - 프로젝트 구조 상세 분석
- [03-components.md](03-components.md) - 구성 요소별 상세 설명
- [04-installation-flow.md](04-installation-flow.md) - 설치 과정 상세 플로우
- [05-verification.md](05-verification.md) - 검증 시스템 상세 설명
- [06-specifications.md](06-specifications.md) - 기술 사양 및 요구사항
- [index.md](index.md) - 서브브랜치 인덱스
