#!/bin/sh
# OpenClaw Worker Boot Script
# Writes config + auth from env vars, updates to latest, then starts the gateway.

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

# Update to latest version (v2026.2.3 → v2026.2.6+ adds openrouter provider support)
echo "[boot] Updating OpenClaw..."
node dist/index.js update --yes 2>&1 || echo "[boot] Update failed or not available, continuing with current version"

# Start the gateway (exec replaces shell with node as PID 1)
export OPENCLAW_STATE_DIR=/root/.openclaw
echo "[boot] Starting gateway..."
exec node dist/index.js gateway
