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
      "apiKey": "${OPENROUTER_API_KEY}"
    }
  }
}
AUTHEOF
echo "[boot] Auth profiles written"

# Update to latest version (may add openrouter support / OPENAI_BASE_URL respect)
echo "[boot] Updating OpenClaw..."
npm i -g openclaw@latest 2>&1 | tail -3
echo "[boot] Version: $(openclaw --version 2>/dev/null || echo 'unknown')"

export OPENCLAW_STATE_DIR=/root/.openclaw
echo "[boot] Starting gateway..."
exec openclaw gateway
