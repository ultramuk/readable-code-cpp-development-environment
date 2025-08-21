# 서브브랜치 문서 인덱스

## 개요

C++ 개발 환경 자동 설정 도구 프로젝트의 상세 문서들입니다. 각 문서는 프로젝트의 특정 측면을 심도있게 다룹니다.

## 문서 구조

### 1. [프로젝트 개요](01-overview.md)

- **내용**: 프로젝트 정의, 프루트(결과물), 전체 구조
- **대상**: 프로젝트 전체를 이해하고자 하는 사용자
- **핵심**: 실제 결과물과 사용 방법 명시

### 2. [프로젝트 구조](02-structure.md)

- **내용**: 스크립트 계층 구조, 디렉터리별 역할, 파일 명명 규칙
- **대상**: 프로젝트 구조를 파악하고자 하는 개발자
- **핵심**: 스크립트 조직과 의존성 관계

### 3. [구성 요소](03-components.md)

- **내용**: 핵심 함수, OS별 유틸리티, 개별 도구 설치 로직
- **대상**: 코드 수정이나 확장을 고려하는 개발자
- **핵심**: 각 구성 요소의 세부 동작 원리

### 4. [설치 플로우](04-installation-flow.md)

- **내용**: 전체 설치 과정, OS별 플로우, 오류 처리
- **대상**: 설치 과정을 이해하거나 문제를 해결하려는 사용자
- **핵심**: 단계별 실행 흐름과 Mermaid 다이어그램

### 5. [검증 시스템](05-verification.md)

- **내용**: 검증 방법, 도구별 테스트, 문제 진단
- **대상**: 설치 결과를 확인하거나 문제를 진단하려는 사용자
- **핵심**: 설치 완료 후 검증 과정

### 6. [기술 사양](06-specifications.md)

- **내용**: 시스템 요구사항, 성능 사양, 호환성 매트릭스
- **대상**: 시스템 관리자나 기술적 요구사항을 확인하려는 사용자
- **핵심**: 지원 플랫폼과 성능 요구사항

## 읽기 순서 가이드

### 신규 사용자

1. [01-overview.md](01-overview.md) - 프로젝트 전체 이해
2. [06-specifications.md](06-specifications.md) - 시스템 요구사항 확인
3. [04-installation-flow.md](04-installation-flow.md) - 설치 과정 이해
4. [05-verification.md](05-verification.md) - 검증 방법 숙지

### 개발자

1. [01-overview.md](01-overview.md) - 프로젝트 개요
2. [02-structure.md](02-structure.md) - 구조 파악
3. [03-components.md](03-components.md) - 구성 요소 분석
4. [04-installation-flow.md](04-installation-flow.md) - 실행 플로우 이해

### 시스템 관리자

1. [06-specifications.md](06-specifications.md) - 기술 사양 검토
2. [05-verification.md](05-verification.md) - 검증 시스템 이해
3. [04-installation-flow.md](04-installation-flow.md) - 설치 플로우 검토
4. [01-overview.md](01-overview.md) - 전체 개요 확인

## 문서 연결 관계

```text
01-overview.md (중심)
├── 02-structure.md (구조 상세)
├── 03-components.md (구현 상세)
├── 04-installation-flow.md (프로세스 상세)
├── 05-verification.md (검증 상세)
└── 06-specifications.md (기술 상세)
```

## 관련 링크

- [메인 README](../README.md) - 프로젝트 메인 문서
- [스크립트 문서](../scripts/README.md) - 스크립트별 상세 설명
- [프로젝트 구조](../PROJECT_STRUCTURE.md) - 전체 파일 구조

## 업데이트 정보

| 문서 | 최종 업데이트 | 주요 변경사항 |
|------|---------------|---------------|
| 01-overview.md | 2025-08-20 | 프루트 섹션 추가, 팩트 기반 재작성 |
| 02-structure.md | 2025-08-20 | 계층적 구조 정리, 테이블 형식 개선 |
| 03-components.md | 2025-08-20 | 구성 요소별 세분화, 코드 예제 추가 |
| 04-installation-flow.md | 2025-08-20 | Mermaid 다이어그램 추가, 플로우 상세화 |
| 05-verification.md | 2025-08-20 | 검증 시스템 완전 재작성 |
| 06-specifications.md | 2025-08-20 | 기술 사양 체계화, 호환성 매트릭스 추가 |

---
