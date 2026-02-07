# OpenClaw Worker

Thin Docker wrapper around `alpine/openclaw:latest` for Railway deployment.

Overrides the ENTRYPOINT to allow shell-based startup scripts that:
1. Write `openclaw.json` config from base64-encoded env var
2. Start the gateway with proper bind address and auth

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `OPENCLAW_CONFIG_B64` | Yes | Base64-encoded openclaw.json config |
| `OPENCLAW_GATEWAY_TOKEN` | Yes | Bearer token for API auth |
| `OPENROUTER_API_KEY` | Yes | API key for model provider |
| `RAILWAY_RUN_UID` | Yes | Set to `0` for volume permissions |
