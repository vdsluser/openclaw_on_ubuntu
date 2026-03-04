#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/systemd/logind.conf"
BACKUP="/etc/systemd/logind.conf.bak.$(date +%Y%m%d_%H%M%S)"

if [[ $EUID -ne 0 ]]; then
  echo "이 스크립트는 root 권한이 필요합니다. 예) sudo $0"
  exit 1
fi

if [[ ! -f "$CONF" ]]; then
  echo "파일이 없습니다: $CONF"
  exit 1
fi

echo "[1/4] 백업 생성: $BACKUP"
cp -a "$CONF" "$BACKUP"

echo "[2/4] logind.conf 설정 적용"

# 1) 기존 설정(주석 포함)을 정리: 해당 키 라인을 모두 제거
# 2) [Login] 섹션에 우리가 원하는 설정을 넣음 (없으면 파일 끝에 섹션 생성)
tmp="$(mktemp)"
awk '
  BEGIN{ in_login=0 }
  /^\[Login\]/{ in_login=1; print; next }
  /^\[.*\]/{ in_login=0; print; next }
  {
    # 기존 키(중복/주석 포함) 제거
    if ($0 ~ /^[#[:space:]]*HandleLidSwitch(ExternalPower|Docked)?[[:space:]]*=/) next
    print
  }
' "$CONF" > "$tmp"

# [Login] 섹션이 있는지 확인
if ! grep -q '^\[Login\]' "$tmp"; then
  printf "\n[Login]\n" >> "$tmp"
fi

# [Login] 섹션 바로 아래에(혹은 파일 끝의 [Login]에) 설정 삽입
# - HandleLidSwitch: 덮개 닫기 동작
# - ExternalPower: 전원 연결 시
# - Docked: 외부 모니터/도킹 상태(환경에 따라 유용)
perl -0777 -pe '
  if (s/^\[Login\]\n/\[Login\]\nHandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore\n/m) {
    # replaced
  } else {
    $_ .= "\n[Login]\nHandleLidSwitch=ignore\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore\n";
  }
' -i "$tmp"

install -m 0644 "$tmp" "$CONF"
rm -f "$tmp"

echo "[3/4] systemd-logind 재시작"
systemctl restart systemd-logind

echo "[4/4] 적용 확인"
echo "현재 logind 설정:"
grep -nE '^\s*(HandleLidSwitch|HandleLidSwitchExternalPower|HandleLidSwitchDocked)\s*=' "$CONF" || true

echo
echo "완료! 이제 덮개를 닫아도 대기/절전으로 들어가지 않도록 설정되었습니다."
