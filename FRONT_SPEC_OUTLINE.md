# 프론트엔드 명세 / 스펙 문서 대목차 표준

## 0. 문서 관리 영역
PM / 아키텍트 / 유지보수자 필수

### 0.1 문서 목적
- 본 문서는 CosmosX 프론트엔드의 현재 구현(Flutter Web/Mobile 기준)을 운영·유지보수 가능한 수준으로 정리한다.
- 화면/라우팅/상태/API/인증 정책을 코드 구현 기준으로 통일한다.

### 0.2 문서 범위
- 포함: Flutter `lib/` 기준 UI, 라우팅, 상태관리(Provider), API 연동, 인증 UI, 반응형 정책.
- 제외: 백엔드 DB 스키마 상세, 서버 내부 로직, 인프라 IaC 상세.

### 0.3 용어 정의 (Glossary)
- Top Menu: 1차 도메인 구분(`nwn`, `comm`, `set`, `member` 성격의 메뉴 그룹).
- Middle Menu: 실제 게시판 엔드포인트 구분(`news`, `notice`, `free`, `record`).
- Details Path: 목록에서 상세로 이동할 때 사용하는 동적 경로(`/:itemIndex`).
- Extra Data: 상세 화면 진입 시 전달하는 보조 데이터(`mappedIds`, `currentIndex`).

### 0.4 약어 정리
- IA: Information Architecture
- A11y: Accessibility
- UX: User Experience
- JWT: JSON Web Token

### 0.5 참조 문서
- 프로젝트 루트 `README.md`
- 프로젝트 메모 `lib/ProjSetInfo.md`
- 본 문서 `FRONT_SPEC_OUTLINE.md`

### 0.6 문서 버전 이력 (Revision History)
- v0.1: 대목차 템플릿 생성
- v0.2: 코드 기반 기능 중심 명세 초안 반영

## 1. 서비스 개요
“이 앱이 뭔지” 한 페이지로 이해

### 1.1 서비스 목표
- 우주/과학 테마 커뮤니티에서 뉴스·공지·자유글·기록형 게시글을 탐색하고 작성/수정한다.
- 인증 사용자 중심으로 게시글 작성/수정 기능 접근을 제어한다.

### 1.2 핵심 사용자 (Persona)
- 비로그인 사용자: 게시글 조회 중심.
- 로그인 사용자(로컬/SNS): 작성, 수정, 마이페이지 이용.
- 운영/관리 관점 사용자: 게시판 구조, 라우팅, 상태·API 연결 유지보수.

### 1.3 주요 기능 요약
- 홈 요약 피드(뉴스/자유/공지 일부 미리보기).
- 게시판 목록/상세/댓글 목록 화면 제공.
- 게시글 작성/수정 화면 제공.
- 로컬 로그인 + 카카오/구글 연동 로그인 처리.
- 사용자 정보 표시 및 로그아웃.

### 1.4 서비스 구조도 (IA 개념)
- 홈
- 새소식(뉴스, 공지/제휴)
- 커뮤니티(자유게시판, 기록/실험)
- 설정
- 회원(로그인/회원가입/회원정보)

### 1.5 화면 흐름도 (User Flow 요약)
- 비로그인: 홈 → 게시판 목록 → 상세 조회
- 로그인: 로그인 → 홈/게시판 → 작성/수정 → 회원정보 확인
- 보호 경로 접근 시: 로그인 여부 검사 후 로그인 화면 리다이렉트

## 2. 설계 원칙 & 아키텍처
프론트엔드의 철학

### 2.1 설계 원칙
- Config-Driven UI
  - 게시판별로 공통 라우트 빌더 패턴을 재사용한다.
- Stateless UI
  - 가능하면 화면은 표현 중심, 상태는 Provider에서 관리한다.
- Single Source of Truth
  - 사용자 인증/프로필 상태는 `UserProvider`를 단일 진실 원천으로 사용한다.

### 2.2 전체 아키텍처 개요
- Presentation Layer: `view/screen`, `view/widget`
- Domain/UI Logic Layer: `routes`, `util`
- Data Layer: `provider` + HTTP/Dio 호출
- 상태 관리 전략: `ChangeNotifier + Provider` 기반

### 2.3 상태 관리 전략
- 전역 상태
  - 사용자 정보/토큰, 게시글 메타 조회수/제목, 공지 선택 데이터
- 화면 상태
  - 로그인 입력값, hover/선택 상태, 페이지 인덱스
- 비동기 상태
  - FutureBuilder 기반 목록/상세 로딩, Provider 비동기 fetch

### 2.4 데이터 흐름 (Data Flow Diagram)
- UI 이벤트 → GoRouter 이동 또는 Provider 메서드 호출
- Provider/API 호출 → 응답 파싱 → notifyListeners
- UI 재빌드 → 목록/상세/회원정보 반영

## 3. 기술 스택
개발자·운영자 공통 기준

### 3.1 프레임워크 & 언어
- Flutter: stable 채널 (프로젝트 `.metadata` revision `2663184aa79047d0a33a14a3b607954f8fdd8730`)
- Dart SDK: `^3.7.2`
- 앱 버전: `1.0.0+1`

### 3.2 주요 라이브러리
- 라우팅/상태/네트워크
  - `go_router: ^8.0.3`
  - `provider: ^6.0.5`
  - `dio: ^5.4.3+1`
  - `http: ^1.1.0`
- 인증/보안
  - `flutter_secure_storage: ^9.2.1`
  - `jwt_decoder: ^2.0.1`
  - `jwt_decode: ^0.3.1`
  - `dart_jsonwebtoken: ^2.14.0`
  - `kakao_flutter_sdk: ^1.9.3`
  - `google_sign_in: ^6.2.1`
- 에디터/작성 화면(글작성 코드 기준)
  - `flutter_inappwebview: ^6.1.5` (웹/모바일 브리지)
  - `universal_html: ^2.2.4` (웹 `window.postMessage` 통신)
  - `uuid: ^4.5.1` (iframe viewType 고유값 생성)
  - `http_parser: ^4.1.2` (이미지 업로드 MIME 처리)
  - `flutter_quill: ^11.2.0`, `flutter_quill_extensions: ^11.0.0`
- 글작성 HTML 에디터(JS/CSS CDN)
  - `quill@2.0.3` (CSS/JS)
  - `quill-resize-image@1.0.7`
  - `quill-table-ui@1.0.7`

### 3.3 상태 관리 라이브러리
- provider (`ChangeNotifierProvider`, `Consumer`, `Provider.of`)

### 3.4 라우팅 방식
- `MaterialApp.router` + `GoRouter`
- `StatefulShellRoute.indexedStack` 기반 멀티 브랜치 네비게이션

### 3.5 네트워크 통신 방식
- 단순 GET은 `http`
- 인증/로그인 및 복합 요청은 `dio`

### 3.6 빌드 & 배포 환경
- Flutter Web/Mobile 대상
- Web URL은 path 전략 사용(`#` 제거)

### 3.7 환경 변수 관리
- 현재 API 호스트는 코드 상수 문자열로 사용 중
- 향후 환경별 분리를 위한 `.env` 또는 빌드 플래그 분리 필요

## 4. 정보 구조 (IA)
화면 구조 설계의 핵심

### 4.1 전체 메뉴 구조
- 홈 / 뉴스 / 자유게시판 / 기록·실험 / 공지·제휴 / 설정 / 회원

### 4.2 네비게이션 구조
- 모바일: Bottom NavigationBar
- 와이드 화면: NavigationRail
- 보조 네비게이션: Drawer(새소식/커뮤니티/설정/로그인)

### 4.3 공통 레이아웃 구조
- Scaffold 기반
- 앱바 + 드로어 + 본문 + (일부 화면) 플로팅 버튼/액션

### 4.4 접근 제한 영역 정의
- 글쓰기/수정 및 회원 화면 일부는 로그인 토큰 기준 접근 제어

### 4.5 다중 게시판 구조 정의
- `news`, `notice`, `free`, `record`를 동일 패턴으로 관리
- 목록(`/board`) → 상세(`/board/:itemIndex`) → 수정(`/update`) 구조

## 5. 화면 목록 (Screen List)
“무슨 화면이 있는지” 정리

### 5.1 화면 목록 표
- 홈, 로그인, 회원정보, 로컬/SNS 회원가입
- 뉴스 목록/상세/댓글
- 공지 목록/상세/댓글
- 자유게시판 목록/상세/댓글
- 기록/실험 목록/상세/댓글
- 글쓰기/수정 화면

### 5.2 화면 ID 규칙
- 도메인_기능_타입 권장
  - 예: `nwn_news_list`, `comm_free_details`, `member_login`

### 5.3 공통 화면 요소
- 공통 네비게이션 바/레일
- 공통 Drawer
- 공통 로그인/로그아웃 위젯

### 5.4 모달 / 바텀시트 / 팝업 목록
- 현재 핵심 흐름은 페이지 전환 중심
- 에러/안내는 다이얼로그/텍스트 표시 방식 사용

## 6. 화면 상세 명세
프론트 명세서의 핵심 파트
(이 섹션이 가장 큼)

### 6.x [화면명]
- 화면 목적
  - 목록 탐색, 상세 조회, 작성/수정, 인증/회원 관리
- 접근 경로
  - 예: `/`, `/nwn/news`, `/comm/free/:itemIndex`, `/login`, `/member`
- 권한 조건
  - 작성/수정/회원정보는 토큰 존재 시 허용
- 상태별 UI (로딩/에러/빈 상태)
  - 로딩: `CircularProgressIndicator`
  - 에러: 텍스트 기반 에러 표시
  - 빈 상태: 기본 문구 표시
- 입력 필드 정의
  - 로그인: 이메일/비밀번호
  - 글쓰기: 제목/본문(에디터)/기타 게시판별 필드
- 버튼 / 액션 정의
  - 로그인, 로그아웃, 상세 이동, 수정 이동, 목록 이동
- 화면 이벤트
  - 탭 시 `context.go(...)`, 상세 진입 시 extraData 전달
- 예외 처리
  - 잘못된 itemIndex, API 실패, 토큰 만료 시 사용자 상태 초기화
- (모든 화면 반복)

## 7. 컴포넌트 명세
재사용 단위 정의

### 7.1 공통 컴포넌트 목록
- 네비게이션(`ScaffoldWithNestedNavigation`)
- Drawer(`BaseDrawer`)
- 로그인/로그아웃 UI(`LoginoutWidget`, `LoginStyle2`)
- 앱바, 게시글 번호 화살표, 에디터 툴바

### 7.2 컴포넌트별 역할
- 네비게이션: 브랜치 전환 + 탭별 데이터 갱신 트리거
- Drawer: 메뉴 묶음 이동
- 로그인 위젯: 로그인 상태 표시/로그아웃 실행

### 7.3 Props 정의
- 네비게이션: `body`, `selectedIndex`, `onDestinationSelected`
- 로그인 화면: `label`, `detailsPath_a`
- 홈/일부 화면: `label`, `detailsPath`

### 7.4 상태 여부 (Stateless / Stateful)
- Stateless: 레이아웃/표현 전용 위젯 중심
- Stateful: 로그인 입력, hover 상태, 슬라이더/페이지 상태

### 7.5 재사용 규칙
- 게시판은 공통 라우트 생성 함수를 우선 사용
- 토큰/유저 상태 접근은 `UserProvider`를 우선 사용

### 7.6 접근성(A11y) 고려사항
- 텍스트/아이콘 조합으로 액션 의미 전달
- SelectableText 사용 구간 유지
- 색상 대비는 추가 점검 필요

## 8. 게시판 / 도메인 특화 UI 명세
서비스 고유 영역

### 8.1 게시판 레이아웃 타입
- 리스트형 목록 + 상세형 본문 + 댓글 목록 결합

### 8.2 게시글 카드 스펙
- 기본 필드: 제목, 작성자 닉네임, 작성일, 조회수
- 목록에서 상세로 이동 가능한 click/tap 영역 제공

### 8.3 post_schema 기반 동적 폼
- 현재는 화면별 작성 UI 분리 구현
- 향후 `post_schema` 표준화 시 동적 폼 통합 대상

### 8.4 리스트/앨범/타임라인 규칙
- 현재 핵심은 리스트 규칙
- 최신순 표기(역순 정렬) 사용

### 8.5 정렬 / 필터 UI 규칙
- 기본 정렬: 최신순
- 고급 필터/복합 정렬 UI는 확장 예정

## 9. 상태 관리 명세
Provider(`ChangeNotifier`) 기반

### 9.1 전역 상태 목록
- `UserProvider`
  - 사용자 식별/프로필: `username`, `nickname`, `email`, `grade`, `provider`, `id`, `sns_id`, `points`
  - 인증 토큰: `accessToken`, `refreshToken`
- `ViewCountProvider`
  - 게시글 메타 캐시: `_postData(Map<int, Map<String, dynamic>>)`
  - 게시글 수량: `_totalPosts`
- `NoticeProvider`
  - 공지 전달 상태: `NoticeData? noticeData`
- `ItemIndexProvider`
  - 상세/전환용 인덱스: `int? itemIndex`
- `QuillEditorController`
  - 전역 Quill 컨트롤러 인스턴스 (`quill.QuillController.basic()`)

### 9.2 Provider / Store 구조
- 앱 루트 `MultiProvider`에서 아래 `ChangeNotifierProvider`를 전역 등록
  - `NoticeProvider`
  - `ItemIndexProvider`
  - `ViewCountProvider`
  - `UserProvider`
  - `QuillEditorController`

### 9.3 상태 생명주기
- 앱 시작
  - `UserProvider` 생성자에서 `loadTokens()` 실행
  - 이후 `checkAccessTokenAndFetchUserData()`로 토큰 유효성 및 사용자 정보 동기화
- 로그인/인증 이후
  - `saveTokens()`으로 SecureStorage + 메모리 상태 동시 저장
  - 로컬 로그인: `fetchUserData()`
  - SNS(카카오) 로그인: `fetchSNSUserData()`
- 라우트/화면 전환
  - 목록 화면 진입 시 `ViewCountProvider.fetchPostDataFromAPI(boardName)` 호출 패턴
  - 상세 이동 인덱스는 `ItemIndexProvider.setItemIndex()`로 전달
- 로그아웃/만료
  - `clearUser()`에서 메모리 상태 초기화 + `jwt_token`, `refresh_token` 삭제

### 9.4 캐시 전략
- 사용자/토큰
  - 영속 스토리지: `FlutterSecureStorage`
  - 런타임 캐시: `UserProvider` 필드
- 게시글 메타
  - 런타임 메모리 캐시(Map)
  - API 조회 결과를 전체 덮어쓰기(`_postData.clear()` 후 재적재)
  - 작성/삭제 시 `addPost()`, `removePost()`로 수동 동기화

### 9.5 invalidate / refresh 정책
- 인증 상태 무효화
  - 토큰 만료(`JwtDecoder.isExpired`) 또는 인증 API 실패 시 `clearUser()` 실행
- 게시글 캐시 갱신
  - 게시판별 목록 진입/재진입 시 `fetchPostDataFromAPI()` 재호출
  - 수동 갱신 필요 시 `updatePostData()` 사용
- 공지/인덱스 보조 상태
  - 이벤트 시점에 setter(`setNoticeData`, `setItemIndex`) 호출 후 `notifyListeners()`

## 10. 라우팅 & 네비게이션
화면 이동 규칙

### 10.1 라우트 목록
- `/`, `/nwn/news`, `/nwn1/notice`, `/comm/free`, `/comm1/record`, `/set`
- `/login`, `/member`, `/localSignup`, `/snsSignup`
- 상세/수정: `/:itemIndex`, `/:itemIndex/update`

### 10.2 동적 라우트 규칙
- 상세 진입 파라미터: `itemIndex`
- 상세 진입 시 `extractMenuMapData1`로 `mappedIds/currentIndex` 구성

### 10.3 인증 가드
- 홈 하위 작성 경로 및 회원 경로는 토큰 존재 여부 검사
- 미인증 시 `/login` 리다이렉트

### 10.4 권한 기반 리다이렉트
- 로그인 상태에서 `/login` 접근 시 회원 페이지 표시
- 비로그인 상태에서 보호 페이지 접근 시 로그인 페이지 이동

### 10.5 딥링크 정책
- 웹 URL 전략은 Path 기반(`setPathUrlStrategy`)을 사용한다.
- OAuth 콜백 경로는 `/auth/kakao/callback`으로 고정한다.
- 게시글 딥링크 표준 경로
  - 목록: `/{topMenu}/{boardCode}`
  - 상세: `/{topMenu}/{boardCode}/:itemIndex`
  - 수정: `/{topMenu}/{boardCode}/:itemIndex/update`
- 딥링크 접근 시 정책
  - 비보호 경로(목록/상세)는 비로그인 접근 허용
  - 보호 경로(작성/수정/회원)는 토큰 검사 후 미인증 시 `/login` 리다이렉트

### 10.6 URL Preview 정책
- URL Preview는 딥링크 라우팅과 별도 기능으로 관리한다.
- 대상 URL: 게시글 상세 URL(`.../:itemIndex`)
- 제공 메타: `title`, `description(요약)`, `og:image` 대표 이미지
- 노출 채널: 카카오톡/메신저/SNS 공유 미리보기
- 운영 기준
  - 웹 진입점(서버/호스팅)에서 Open Graph 메타를 일관되게 제공한다.
  - 미리보기 노출 실패는 공유 유입 손실 이슈로 분류하여 점검한다.

## 11. API 연동 명세
백엔드와의 계약

### 11.1 API 호출 규칙
- GET 목록/조회: `https://api.cosmosx.co.kr/{board}/`
- 인증 API: 로그인, 토큰 검증, SNS 인증 엔드포인트 사용

### 11.2 요청/응답 포맷
- JSON 기준
- 상세 화면 이동 보조값은 프론트에서 `mappedIds/currentIndex`로 가공

### 11.3 에러 코드 처리 기준
- 상태코드 비정상 시 예외 throw 또는 에러 텍스트 표시
- 사용자 알림은 화면 내 메시지/다이얼로그 중심

### 11.4 재시도 정책
- 현재 자동 재시도 공통 정책은 없음
- 필요 시 사용자 재진입/재요청으로 처리

### 11.5 파일 업로드 정책
- 글쓰기 화면에서 업로드 기능 확장 가능 구조
- 용량/포맷/실패 재시도 규칙은 추후 명문화 필요

## 12. 인증 & 권한 UI 명세
보안·UX 핵심

### 12.1 로그인 상태 정의
- 로그인 판정: `accessToken` 존재 + 유저 식별값 존재

### 12.2 권한별 UI 노출 기준
- 비로그인: 로그인 버튼, 공개 목록/상세
- 로그인: 회원정보/로그아웃, 작성/수정 경로 접근

### 12.3 토큰 만료 처리
- 로컬 사용자 토큰 만료 시 사용자 상태 초기화
- 초기 진입 시 토큰 로드 및 만료 체크 수행

### 12.4 강제 로그아웃 시나리오
- 수동 로그아웃 시 SecureStorage 전체 삭제
- 카카오/구글 연동 로그아웃 처리 시도 후 홈 이동

## 13. UX 정책
디자이너 + 개발자 공통

### 13.1 로딩 정책
- FutureBuilder/비동기 호출 구간에서 로딩 인디케이터 표시

### 13.2 에러 메시지 규칙
- 사용자 이해 가능한 문자열 우선
- 개발 로그는 콘솔 출력으로 분리

### 13.3 토스트 / 스낵바 사용 기준
- 현재는 인라인 메시지/화면 텍스트 중심
- 스낵바 표준은 추후 통합 권장

### 13.4 빈 상태 UX
- “데이터 없음” 계열 기본 문구로 공백 상태 안내

### 13.5 확인/경고 다이얼로그 기준
- 로그아웃/삭제 등 파괴적 액션은 확인 UI 도입 권장

## 14. 반응형 & 플랫폼 대응
Flutter / Web / Mobile 공통

### 14.1 브레이크포인트
- 약 450px 기준으로 하단 바 ↔ 레일 전환

### 14.2 모바일/태블릿/데스크톱 차이
- 모바일: Bottom Navigation 중심
- 데스크톱/와이드: NavigationRail + 본문 확장

### 14.3 플랫폼별 UX 차이
- 웹: Path URL 전략, OAuth 콜백 경로 활용
- 모바일: SNS SDK 로그인 흐름 중심

### 14.4 키보드 / 포커스 정책
- 로그인 입력 필드 중심 기본 포커스 사용
- 데스크톱 키보드 탐색 고도화는 추후 과제
- 
## 15. 접근성 (A11y)
요즘 기업 필수

### 15.1 접근성 목표
- 주요 기능을 텍스트/아이콘 조합으로 명확히 전달

### 15.2 스크린 리더 대응
- 의미 있는 라벨/텍스트 유지
- 커스텀 위젯의 semantics 보강 필요

### 15.3 색상 대비 기준
- 테마 색상 사용 시 대비 검증 필요

### 15.4 키보드 네비게이션
- 웹/데스크톱 기본 탭 이동 가능
- 포커스 시각화 표준은 추가 정의 필요

## 16. 성능 기준
운영 단계 필수

### 16.1 초기 로딩 기준
- 초기 진입 시 필수 Provider 초기화 + 최소 데이터 로딩

### 16.2 스크롤 성능
- 목록은 `ListView` 기반
- 중첩 스크롤 구간은 `shrinkWrap` 사용 시 성능 점검 필요

### 16.3 이미지 최적화
- 아이콘/정적 에셋 중심
- 대용량 이미지 업로드/렌더링 규칙은 추후 확정

### 16.4 캐싱 정책
- Provider 메모리 캐시 우선
- 강한 캐시 무효화 정책은 도메인별 확장 필요

## 17. 로깅 & 분석
운영/개선용

### 17.1 로그 수집 기준
- 현재 콘솔 로그(print) 중심
- 운영 환경에서는 레벨별 로깅 체계 분리 필요

### 17.2 사용자 행동 이벤트
- 라우트 접근, 로그인 성공/실패, 게시글 이동 이벤트 우선 수집 권장

### 17.3 에러 추적
- API 실패/토큰 오류/라우트 파라미터 오류 추적 필요

### 17.4 관리자용 분석 지표
- 게시판별 조회수/진입수/이탈률
- 로그인 방식별 성공률(로컬, 카카오, 구글)

## 18. 테스트 전략
QA 기준

### 18.1 테스트 범위
- 라우트 가드, 인증 상태 전이, 목록/상세 로딩

### 18.2 단위 테스트 기준
- 유틸 함수(`extractMiddleMenu`, 토큰 만료 체크) 단위 테스트 권장

### 18.3 위젯/UI 테스트
- 로그인 화면 입력/버튼 액션
- 네비게이션 탭 전환/경로 이동

### 18.4 E2E 테스트
- 로그인 → 게시판 이동 → 상세 → 로그아웃 시나리오

## 19. 배포 & 운영
실서비스 기준

### 19.1 빌드 전략
- Flutter Web 빌드 및 플랫폼별 앱 빌드 분리

### 19.2 환경별 설정
- dev/stage/prod API 호스트 분리 필요

### 19.3 버전 관리 정책
- 기능 단위 커밋 + 문서 동기화

### 19.4 롤백 전략
- 배포 아티팩트 버전 태깅 + 직전 안정 버전 복귀

## 20. 제한사항 & 향후 확장
미래 대비

### 20.1 현재 제한사항
- API 호스트 하드코딩 비중
- 에러 처리/재시도 표준 부족
- A11y/분석 이벤트 체계 미완성

### 20.2 기술 부채
- 일부 화면/라우트 파일 중복 패턴 존재
- 주석/실험 코드 정리 필요

### 20.3 확장 계획
- 게시판 스키마 기반 동적 화면 통합
- 인증 가드/권한 정책 중앙화
- 환경 분리 및 공통 네트워크 인터셉터 도입

## 21. 부록
참고 자료

### 21.1 화면 캡처
- 추후 주요 화면(홈/목록/상세/로그인/회원) 캡처 추가

### 21.2 API 샘플
- 로그인, 게시판 목록, 상세 조회 API 샘플 추가 예정

### 21.3 에러 코드 표
- 인증 실패/권한 없음/파라미터 오류/서버 오류 기준 정리 예정

### 21.4 FAQ
- 로그인 실패, 토큰 만료, 상세 접근 실패 등 운영 FAQ 추가 예정

---

## 네 프로젝트 기준으로 핵심 강조 구간 🔥
너 서비스 기준에서 특히 중요한 대목차는:

- 6. 화면 상세 명세
- 8. 게시판 / 도메인 특화 UI
- 9. 상태 관리 명세
- 10. 라우팅 & 인증 가드
- 11. API 연동 명세
