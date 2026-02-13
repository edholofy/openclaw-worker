#!/bin/sh
# OpenClaw Worker Boot Script
set -e

mkdir -p /root/.openclaw/agents/main/agent /data/workspace

echo "$OPENCLAW_CONFIG_B64" | base64 -d > /root/.openclaw/openclaw.json
echo "[boot] Config written"

cat > /root/.openclaw/agents/main/agent/auth-profiles.json << AUTHEOF
{
  "profiles": {
    "anthropic:default": {
      "type": "api_key",
      "provider": "anthropic",
      "apiKey": "${ANTHROPIC_API_KEY}"
    }
  }
}
AUTHEOF
echo "[boot] Auth profiles written"

# Decode workspace files from OPENCLAW_WORKSPACE_B64 (JSON array of {path, content}).
# Written at boot because /tools/invoke is only available during active sessions.
if [ -n "$OPENCLAW_WORKSPACE_B64" ]; then
  echo "$OPENCLAW_WORKSPACE_B64" | base64 -d | node -e "
    const fs = require('fs');
    const path = require('path');
    let buf = '';
    process.stdin.on('data', d => buf += d);
    process.stdin.on('end', () => {
      const files = JSON.parse(buf);
      files.forEach(f => {
        const full = '/data/workspace/' + f.path;
        fs.mkdirSync(path.dirname(full), {recursive: true});
        fs.writeFileSync(full, f.content);
      });
      console.log('[boot] Wrote ' + files.length + ' workspace files');
    });
  "
  # Install E2B SDK if helper is present and not already installed
  if [ -f /data/workspace/.e2b/package.json ] && [ -n "$E2B_API_KEY" ]; then
    if [ ! -d /data/workspace/.e2b/node_modules/@e2b ]; then
      echo "[boot] Installing E2B SDK..."
      (cd /data/workspace/.e2b && npm install --production 2>&1 | tail -3)
      echo "[boot] E2B SDK installed"
    fi
  fi
fi

export OPENCLAW_STATE_DIR=/root/.openclaw
echo "[boot] Starting gateway..."
exec node dist/index.js gateway
