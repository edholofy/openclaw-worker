#!/bin/sh
# OpenClaw Worker Boot Script
# Writes config + auth from env vars, then starts the gateway.

set -e

# Create required directories
mkdir -p /root/.openclaw/agents/main/agent /data/workspace

# Write openclaw.json from base64 env var
echo "$OPENCLAW_CONFIG_B64" | base64 -d > /root/.openclaw/openclaw.json
echo "[boot] Config written"

# Write auth-profiles.json with API keys for all providers
# OpenClaw uses this file to authenticate with model providers.
# We map OPENROUTER_API_KEY to both openrouter and openai providers
# (openai provider is configured via OPENAI_BASE_URL to point to OpenRouter)
cat > /root/.openclaw/agents/main/agent/auth-profiles.json << AUTHEOF
{
  "profiles": {
    "openrouter:default": {
      "type": "api_key",
      "provider": "openrouter",
      "apiKey": "${OPENROUTER_API_KEY}"
    },
    "openai:default": {
      "type": "api_key",
      "provider": "openai",
      "apiKey": "${OPENAI_API_KEY:-$OPENROUTER_API_KEY}"
    }
  }
}
AUTHEOF
echo "[boot] Auth profiles written"

# Start the gateway (exec replaces shell with node as PID 1)
export OPENCLAW_STATE_DIR=/root/.openclaw
echo "[boot] Starting gateway..."
exec node dist/index.js gateway
