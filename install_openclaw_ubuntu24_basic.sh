#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " OpenClaw Basic Installer (Ubuntu 24.04 LTS)"
echo "=============================================="

# 1) 기본 패키지
echo "[1/7] Installing base packages..."
sudo apt-get update -y
sudo apt-get install -y curl ca-certificates git openssh-server

# 2) OpenClaw 공식 설치 스크립트
echo "[2/7] Installing OpenClaw via official script..."
curl -fsSL https://get.openclaw.ai | bash

# PATH 반영
export PATH="$HOME/.openclaw/bin:$PATH"

# bashrc에 PATH 고정
if ! grep -q '.openclaw/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.openclaw/bin:$PATH"' >> "$HOME/.bashrc"
fi

# 3) 설치 확인
echo "[3/7] Verifying installation..."
openclaw --version

# 4) 워크스페이스 초기화
echo "[4/7] Initializing workspace..."
openclaw init || true

# 5) Gateway systemd user 서비스 설치
echo "[5/7] Installing gateway service..."
openclaw gateway install || true

# 6) Telegram IPv6 이슈 방지 (IPv4 우선)
echo "[6/7] Applying IPv4-first DNS override..."
OVR_DIR="$HOME/.config/systemd/user/openclaw-gateway.service.d"
mkdir -p "$OVR_DIR"

cat > "$OVR_DIR/override.conf" <<'EOF'
[Service]
Environment=NODE_OPTIONS=--dns-result-order=ipv4first
EOF

systemctl --user daemon-reload
systemctl --user enable --now openclaw-gateway.service

# 로그인 없이도 서비스 유지 (서버 권장)
sudo loginctl enable-linger "$USER" || true

# 7) 상태 확인
echo "[7/7] Gateway status:"
systemctl --user status openclaw-gateway.service --no-pager

echo ""
echo "=============================================="
echo " 설치 완료"
echo "=============================================="
echo ""
echo "다음 단계:"
echo "1) 새 터미널 열거나: source ~/.bashrc"
echo "2) Telegram 봇 토큰 설정:"
echo "   openclaw channel telegram set"
echo "3) Telegram에서 /start"
echo "4) Pairing code 승인:"
echo "   openclaw pairing approve telegram <CODE>"
echo ""
echo "로그 확인:"
echo "journalctl --user -u openclaw-gateway.service -f"
echo ""
