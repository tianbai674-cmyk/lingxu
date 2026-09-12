#!/usr/bin/env bash
# 灵枢方案页：本地静态服务 + 公网隧道
#
# 用法：  bash serve.sh          （默认端口 8899）
#        PORT=9000 bash serve.sh （自定义端口）
#
# 说明：隧道走 localhost.run 的匿名通道，不需要注册账号。
#      匿名通道每次启动都会分配一个新的随机域名，进程结束后链接即失效。
#      想要固定域名，需要到 https://admin.localhost.run/ 注册并配置 SSH key。

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${PORT:-8899}"
URL_FILE="$DIR/public-url.txt"
LOG_FILE="$DIR/tunnel.log"

cleanup() {
  [ -n "${HTTP_PID:-}" ] && kill "$HTTP_PID" 2>/dev/null || true
  [ -n "${TUNNEL_PID:-}" ] && kill "$TUNNEL_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# 1. 本地静态服务：只暴露本目录
python3 -m http.server "$PORT" --bind 0.0.0.0 --directory "$DIR" >/dev/null 2>&1 &
HTTP_PID=$!
sleep 1

if ! curl -s -o /dev/null --max-time 3 "http://127.0.0.1:$PORT/"; then
  echo "本地服务启动失败，端口 $PORT 可能已被占用。"
  exit 1
fi
echo "本地地址: http://127.0.0.1:$PORT/"

# 2. 公网隧道
: > "$LOG_FILE"
ssh -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ServerAliveInterval=30 \
    -o ExitOnForwardFailure=yes \
    -R 80:localhost:"$PORT" nokey@localhost.run > "$LOG_FILE" 2>&1 &
TUNNEL_PID=$!

PUBLIC_URL=""
for _ in $(seq 1 40); do
  PUBLIC_URL="$(grep -oE 'https://[a-zA-Z0-9.-]+\.lhr\.life' "$LOG_FILE" 2>/dev/null | head -1 || true)"
  [ -n "$PUBLIC_URL" ] && break
  sleep 1
done

if [ -z "$PUBLIC_URL" ]; then
  echo "隧道建立失败，请查看 $LOG_FILE"
  exit 1
fi

printf '%s\n' "$PUBLIC_URL" > "$URL_FILE"
echo "公网地址: $PUBLIC_URL"
echo "（已写入 ${URL_FILE}）"
echo
echo "按 Ctrl+C 关闭。关闭后公网地址立即失效。"

wait "$TUNNEL_PID"
