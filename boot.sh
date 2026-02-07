#!/bin/sh
# OpenClaw Worker Boot Script
# Updates OpenClaw, writes config + auth from env vars, then starts the gateway.

set -e

# Create required directories
mkdir -p /root/.openclaw/agents/main/agent /data/workspace

# Write openclaw.json from base64 env var
echo "$OPENCLAW_CONFIG_B64" | base64 -d > /root/.openclaw/openclaw.json
echo "[boot] Config written"

# Write auth-profiles.json with API keys for providers
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
echo "[boot] Auth profiles written"

# Update to latest version via npm (v2026.2.3 doesn't support openrouter model routing)
echo "[boot] Updating OpenClaw via npm..."
npm i -g openclaw@latest 2>&1 | tail -3
echo "[boot] Update complete"

# Start the gateway (exec replaces shell with node as PID 1)
export OPENCLAW_STATE_DIR=/root/.openclaw
echo "[boot] Starting gateway..."
exec openclaw gateway
