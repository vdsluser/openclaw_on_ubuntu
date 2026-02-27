#!/usr/bin/env bash
set -euo pipefail

echo "====================================================="
echo " OpenClaw Post-Install Service Setup (Ubuntu 24.04)"
echo " - PATH + gateway service install/enable + status"
echo "====================================================="
echo ""

note(){ echo -e "\n[INFO] $*\n"; }
warn(){ echo -e "\n[WARN] $*\n"; }
die(){  echo -e "\n[ERROR] $*\n"; exit 1; }

# 0) openclaw 존재 확인
if [ ! -x "$HOME/.openclaw/bin/openclaw" ] && ! command -v openclaw >/dev/null 2>&1; then
  die "openclaw가 아직 설치되지 않았습니다. 먼저 아래를 실행하세요:\n  curl -fsSL https://openclaw.ai/install.sh | bash"
fi

# 1) PATH 적용(현재 + 영구)
note "[1/6] Setting PATH..."
export PATH="$HOME/.openclaw/bin:$PATH"
if [ -f "$HOME/.bashrc" ]; then
  if ! grep -q 'export PATH="$HOME/.openclaw/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.openclaw/bin:$PATH"' >> "$HOME/.bashrc"
  fi
else
  warn "~/.bashrc가 없어 PATH 영구 적용을 건너뜁니다."
fi

# 2) 버전 확인
note "[2/6] Verifying installation..."
openclaw --version

# 3) 워크스페이스 초기화(이미 되어있으면 무시)
note "[3/6] Initializing workspace..."
openclaw init || true

# 4) gateway systemd user 서비스 설치(유닛 생성/설치)
note "[4/6] Installing gateway service unit..."
openclaw gateway install || true

# 5) systemctl --user 동작 점검 후 enable/start
note "[5/6] Enabling and starting user service..."
if ! systemctl --user daemon-reload >/dev/null 2>&1; then
  warn "systemctl --user 버스 연결에 실패했습니다."
  warn "보통 SSH 세션/로그인 세션 문제일 수 있습니다."
  warn "대응: (1) 재로그인  (2) linger 확인: loginctl show-user $USER | grep Linger"
else
  systemctl --user enable --now openclaw-gateway.service || true
fi

# 6) 상태 출력
note "[6/6] Service status:"
systemctl --user status openclaw-gateway.service --no-pager || true

echo ""
echo "-----------------------------------------------------"
echo "다음 단계:"
echo "  1) 새 터미널 열거나: source ~/.bashrc"
echo "  2) Telegram 봇 토큰 설정: openclaw channel telegram set"
echo "  3) Telegram에서 /start"
echo "  4) Pairing 승인: openclaw pairing approve telegram <CODE>"
echo ""
echo "로그 확인:"
echo "  journalctl --user -u openclaw-gateway.service -f"
echo "-----------------------------------------------------"
echo ""
