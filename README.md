# 🦞 OpenClaw on Ubuntu 24.04 LTS

Ubuntu 24.04 LTS 서버에 **OpenClaw를 안정적으로 설치하고 Telegram
연동까지 완료**하기 위한 자동 설치 스크립트입니다.

이 스크립트는 다음을 자동으로 구성합니다:

-   OpenClaw 기본 설치 (공식 스크립트 방식)
-   systemd user gateway 서비스 등록
-   재부팅 후 자동 실행
-   Telegram IPv6 연결 문제 방지 (IPv4 우선 설정)
-   SSH 서버 환경에서 안정 동작

------------------------------------------------------------------------

## 📦 지원 환경

-   Ubuntu 24.04 LTS
-   SSH 서버 환경
-   내부망 / VPS 모두 가능

------------------------------------------------------------------------

# 🚀 빠른 설치 (한 줄 실행)

``` bash
curl -fsSL https://raw.githubusercontent.com/vdsluser/openclaw_on_ubuntu/main/install_openclaw_ubuntu24_basic.sh | bash
```

curl이 없다면:

``` bash
wget -qO- https://raw.githubusercontent.com/vdsluser/openclaw_on_ubuntu/main/install_openclaw_ubuntu24_basic.sh | bash
```

------------------------------------------------------------------------

# 🔐 보안 권장 설치 방법 (git clone 방식)

``` bash
sudo apt update -y
sudo apt install -y git

git clone https://github.com/vdsluser/openclaw_on_ubuntu.git
cd openclaw_on_ubuntu
chmod +x install_openclaw_ubuntu24_basic.sh
./install_openclaw_ubuntu24_basic.sh
```

------------------------------------------------------------------------

# 🤖 Telegram 연결 방법

## 1️⃣ 새 터미널 열기 또는 PATH 반영

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

이 스크립트는:

-   systemd user 서비스 등록
-   linger 활성화

를 수행하므로 **SSH 로그아웃 후에도 게이트웨이가 계속 실행됩니다.**

------------------------------------------------------------------------

# 🌐 IPv6 관련 안내

Ubuntu 24.04에서는 일부 환경에서 Telegram API 호출 시 IPv6 경로 오류가
발생할 수 있습니다.

이 스크립트는:

    NODE_OPTIONS=--dns-result-order=ipv4first

설정을 통해 IPv4 우선 연결을 강제하여 문제를 방지합니다.

------------------------------------------------------------------------

# ❗ 문제 해결

### gateway connect failed: pairing required

→ 먼저 Telegram에서 `/start` 실행 후\
→ 표시된 Pairing code를 승인해야 합니다.

------------------------------------------------------------------------

### telegram setMyCommands failed

→ 대부분 IPv6 경로 문제\
→ 서비스 재시작:

``` bash
systemctl --user restart openclaw-gateway.service
```

------------------------------------------------------------------------

# 📁 파일 구조

    install_openclaw_ubuntu24_basic.sh
    README.md

------------------------------------------------------------------------

# 🔄 업데이트

OpenClaw 최신 버전 업데이트:

``` bash
curl -fsSL https://get.openclaw.ai | bash
```

서비스 재시작:

``` bash
systemctl --user restart openclaw-gateway.service
```

------------------------------------------------------------------------

# 📜 라이선스

MIT License (또는 원하는 라이선스 명시)

------------------------------------------------------------------------

# ⭐ 기여

Pull Request 및 Issue 환영합니다.
