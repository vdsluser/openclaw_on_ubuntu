# 🦞 OpenClaw on Ubuntu 24.04 LTS

Ubuntu 24.04 LTS 서버에 **OpenClaw를 안정적으로 설치하고 Telegram
연동까지 완료**하기 위한 단계별 설치 가이드입니다.

이 저장소는 다음 3단계 방식으로 구성됩니다:

1.  서버 환경 설정 (IPv6 처리 + linger)
2.  OpenClaw 공식 설치
3.  gateway 서비스 자동 실행 구성

------------------------------------------------------------------------

# 📦 지원 환경

-   Ubuntu 24.04 LTS
-   SSH 서버 환경
-   VPS / 클라우드 / 내부망 서버

------------------------------------------------------------------------

# 🚀 전체 설치 순서 (권장 방식)

## 1️⃣ 서버 환경 설정

``` bash
sudo apt-get update -y
sudo apt-get install -y curl ca-certificates git openssh-server systemd
```

``` bash
curl -fsSL https://raw.githubusercontent.com/vdsluser/openclaw_on_ubuntu/main/00_env_setup.sh | bash
```

설정 완료 후 권장:

``` bash
sudo reboot
```

이 단계에서 수행되는 작업:

-   필수 패키지 설치
-   IPv6 서버 레벨 비활성화 (sysctl)
-   systemd user linger 활성화

------------------------------------------------------------------------

## 2️⃣ OpenClaw 공식 설치

``` bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

설치 완료 후 새 터미널 열거나:

``` bash
source ~/.bashrc
```

------------------------------------------------------------------------

## 3️⃣ gateway 서비스 자동 실행 설정

``` bash
curl -fsSL https://raw.githubusercontent.com/vdsluser/openclaw_on_ubuntu/main/10_openclaw_service_setup.sh | bash
```

이 단계에서 수행되는 작업:

-   PATH 영구 설정
-   워크스페이스 초기화
-   gateway systemd user 서비스 등록
-   자동 실행(enable)
-   상태 확인

------------------------------------------------------------------------

# 🔐 보안 권장 방식 (git clone)

``` bash
sudo apt update -y
sudo apt install -y git

git clone https://github.com/vdsluser/openclaw_on_ubuntu.git
cd openclaw_on_ubuntu
chmod +x 00_env_setup.sh
chmod +x 10_openclaw_service_setup.sh

./00_env_setup.sh
sudo reboot

# 재접속 후
curl -fsSL https://openclaw.ai/install.sh | bash
./10_openclaw_service_setup.sh
```

------------------------------------------------------------------------

# 🤖 Telegram 연결 방법

## 1️⃣ PATH 반영

``` bash
source ~/.bashrc
```

## 2️⃣ Telegram Bot 토큰 설정

``` bash
openclaw channel telegram set
```

BotFather에서 발급받은 토큰 입력

## 3️⃣ Telegram에서 봇 채팅창 열기

    /start

## 4️⃣ 표시되는 Pairing code 승인

``` bash
openclaw pairing approve telegram <PAIRING_CODE>
```

## 5️⃣ 상태 확인

``` bash
openclaw status
```

------------------------------------------------------------------------

# 🔍 서비스 상태 확인

``` bash
systemctl --user status openclaw-gateway.service
```

실시간 로그 보기:

``` bash
journalctl --user -u openclaw-gateway.service -f
```

------------------------------------------------------------------------

# 🔁 재부팅 후 자동 실행

-   systemd user 서비스 등록
-   linger 활성화

SSH 로그아웃 후에도 gateway가 유지됩니다.

------------------------------------------------------------------------

# 🌐 IPv6 관련 안내

Ubuntu 24.04 일부 환경에서 Telegram API 호출 시 IPv6 경로 오류가 발생할
수 있습니다.

본 설치 방식은:

-   커널 레벨에서 IPv6 비활성화 (sysctl 방식)

을 적용하여 안정적으로 IPv4 경로만 사용하도록 구성합니다.

IPv6가 필요한 서버에서는 환경 설정 스크립트를 수정 후 사용하십시오.

------------------------------------------------------------------------

# ❗ 문제 해결

### gateway connect failed: pairing required

→ Telegram에서 `/start` 실행 후\
→ 표시된 Pairing code를 승인해야 합니다.

------------------------------------------------------------------------

### systemctl --user 연결 실패

확인:

``` bash
loginctl show-user $USER | grep Linger
```

재로그인 후 다시 시도하십시오.

------------------------------------------------------------------------

# 🔄 OpenClaw 업데이트

``` bash
curl -fsSL https://get.openclaw.ai | bash
```

서비스 재시작:

``` bash
systemctl --user restart openclaw-gateway.service
```

------------------------------------------------------------------------

# 📁 파일 구조

    00_env_setup.sh
    10_openclaw_service_setup.sh
    README.md

------------------------------------------------------------------------

# 📜 라이선스

MIT License

------------------------------------------------------------------------

# ⭐ 기여

Issue / Pull Request 환영합니다.
