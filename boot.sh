#!/bin/sh
# OpenClaw Worker Boot Script
set -e

mkdir -p /root/.openclaw/agents/main/agent /data/workspace

echo "$OPENCLAW_CONFIG_B64" | base64 -d > /root/.openclaw/openclaw.json
echo "[boot] Config written"

export OPENCLAW_STATE_DIR=/root/.openclaw

# Use openclaw onboard to properly register OpenRouter provider
# The Docker image has node dist/index.js, not a global `openclaw` binary
echo "[boot] Running onboard for OpenRouter..."
node dist/index.js onboard --auth-choice apiKey --token-provider openrouter --token "$OPENROUTER_API_KEY" 2>&1 || {
  echo "[boot] Onboard failed, writing auth profile manually"
  cat > /root/.openclaw/agents/main/agent/auth-profiles.json << AUTHEOF
{
  "profiles": {
    "openrouter:default": {
      "type": "api_key",
      "provider": "openrouter",
      "apiKey": "${OPENROUTER_API_KEY}"
    }
  }
}
AUTHEOF
}
echo "[boot] Auth configured"

echo "[boot] Starting gateway..."
exec node dist/index.js gateway
