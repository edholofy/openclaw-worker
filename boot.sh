#!/bin/sh
# OpenClaw Worker Boot Script
set -e

mkdir -p /root/.openclaw/agents/main/agent /data/workspace

echo "$OPENCLAW_CONFIG_B64" | base64 -d > /root/.openclaw/openclaw.json
echo "[boot] Config written"

# Debug: check if env var is set
echo "[boot] OPENROUTER_API_KEY length: ${#OPENROUTER_API_KEY}"

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
echo "[boot] Auth file contents:"
cat /root/.openclaw/agents/main/agent/auth-profiles.json

# Update to latest
npm i -g openclaw@latest 2>&1 | tail -1

export OPENCLAW_STATE_DIR=/root/.openclaw
echo "[boot] Starting gateway..."
exec openclaw gateway
