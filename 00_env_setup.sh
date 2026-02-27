#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo " OpenClaw Environment Setup (Ubuntu 24.04)"
echo " - Server-level IPv6 disable + base packages"
echo "=============================================="
echo ""

note(){ echo -e "\n[INFO] $*\n"; }
warn(){ echo -e "\n[WARN] $*\n"; }
die(){  echo -e "\n[ERROR] $*\n"; exit 1; }

# 1) 기본 패키지
note "[1/4] Installing base packages..."
sudo apt-get update -y
sudo apt-get install -y curl ca-certificates git openssh-server systemd

# 2) 서버 레벨 IPv6 비활성화 (영구)
note "[2/4] Disabling IPv6 at kernel level (persistent)..."
sudo tee /etc/sysctl.d/99-disable-ipv6.conf >/dev/null <<'EOF'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sudo sysctl --system >/dev/null || true

note "IPv6 status check (may require reboot to fully disappear):"
if ip -o addr show | grep -q "inet6"; then
  warn "현재 inet6가 보입니다. 재부팅 후 완전 적용될 수 있습니다."
else
  note "inet6가 보이지 않습니다. IPv6 비활성화가 적용된 상태입니다."
fi

# 3) 로그인 없이도 user 서비스 유지(서버에서 중요)
note "[3/4] Enabling linger for current user..."
sudo loginctl enable-linger "$USER" || true

# 4) 마무리 안내
note "[4/4] Done."
echo "다음 단계:"
echo "  1) (권장) 재부팅: sudo reboot"
echo "  2) 재접속 후 OpenClaw 설치:"
echo "     curl -fsSL https://openclaw.ai/install.sh | bash"
echo ""
