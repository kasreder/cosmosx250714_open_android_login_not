# widgets
공통으로 사용되는 위젯(여러 화면에서 사용되는 재사용 가능한 위젯)
1. Stateless widgets
2. Stateful widgets
3. Inherited widgets

# route.dart : 애플리케이션의 경로와 탐색을 정의합니다.
# constants.dart : API 엔드포인트 또는 테마 색상과 같이 애플리케이션 전체에서 사용되는 상수 값


   models : 이 폴더에는 애플리케이션에서 사용되는 데이터 모델이 포함됩니다.
   screens : 이 폴더에는 애플리케이션의 개별 화면 또는 페이지가 포함되어 있습니다.
   services : 이 폴더에는 API 호출, 데이터 저장소 또는 기타 서비스를 처리하기 위한 클래스가 포함되어 있습니다.
   utils : 이 폴더에는 응용 프로그램 전체에서 사용되는 유틸리티 기능 또는 도우미 클래스가 포함되어 있습니다.
   
#  mysql -u root -p

flutter build web --no-tree-shake-icons 

인증확인

certbot certificates

service nginx stop
sudo service nginx stop
sudo systemctl stop nginx

certbot renew


단순조회 get 쿼리 조회
인증 글작성 업데이트 post

깃깃


sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license

flutter emulators --launch ios



프로젝트 재생성시 꼭 해야할 작업



2. Flutter 3.24.3 설치
   FVM을 사용하여 Flutter 3.24.3을 설치합니다:

sh
코드 복사
fvm install 3.24.3

3. Flutter 3.24.3 사용 설정
   글로벌 설정 (모든 프로젝트에서 사용):

sh
코드 복사
fvm global 3.24.3
특정 프로젝트에서만 사용:

프로젝트 디렉토리로 이동한 후:

sh
코드 복사
cd /path/to/your/project
fvm use 3.24.3
이렇게 하면 해당 프로젝트에서만 Flutter 3.24.3을 사용하게 됩니다.


flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
http://10.0.2.2:8080/


# 개인키와 인증서를 동시에 생성하는 명령어
openssl req \
-x509 \                      # X.509 인증서 생성 모드 (자체 서명 방식)
-newkey rsa:2048 \           # 새 RSA 키 쌍을 2048비트로 생성
-keyout dev/localhost.key \  # 출력될 개인키 파일 경로
-out dev/localhost.cert.pem \# 출력될 인증서 파일 경로
-days 365 \                  # 인증서 유효기간을 365일로 설정
-nodes \                     # 개인키에 암호(passphrase) 없이 저장
-subj "/CN=localhost"        # 인증서의 주체(Subject) 정보, 여기서는 Common Name을 localhost로 지정


flutter run -d web-server \
--web-port=8080 \
--web-hostname=0.0.0.0 \
--web-tls-cert-path=dev/localhost.cert.pem \
--web-tls-cert-key-path=dev/localhost.key



안드로이드 스튜디오 코드 자동정렬
[Mac OS]맥의 경우 Command + Option + L
[Windows]윈도우즈의 경우 Ctrl + Alt + L

📡 ✅ ❌🔄 


| 목적                            | 등록 경로                    | 접근 경로                             | 비고                         |
| ----------------------------- | ------------------------ | --------------------------------- | -------------------------- |
| Flutter Web에서 iframe에 삽입      | `poke/editor/index.html` | `/assets/poke/editor/index.html`  | `pubspec.yaml`에 등록 필수      |
| WebView에서 사용 (`InAppWebView`) | `poke/editor/index.html` | `asset:///poke/editor/index.html` | `WebUri()` 사용, 에셋 등록 필수    |
| 실제 빌드 위치                      | 자동 복사됨                   | `build/web/assets/...`            | 직접 접근 불가, `/assets/` 통해 접근 |
