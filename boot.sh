#!/bin/sh
# OpenClaw Worker Boot Script
set -e

mkdir -p /root/.openclaw/agents/main/agent /data/workspace

echo "$OPENCLAW_CONFIG_B64" | base64 -d > /root/.openclaw/openclaw.json
echo "[boot] Config written"

cat > /root/.openclaw/agents/main/agent/auth-profiles.json << AUTHEOF
{
  "profiles": {
    "openai:default": {
      "type": "api_key",
      "provider": "openai",
      "apiKey": "${OPENAI_API_KEY}"
    }
  }
}
AUTHEOF
echo "[boot] Auth profiles written"

export OPENCLAW_STATE_DIR=/root/.openclaw
echo "[boot] Starting gateway..."
exec node dist/index.js gateway
