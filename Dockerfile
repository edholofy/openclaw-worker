FROM alpine/openclaw:latest

# Override ENTRYPOINT so Railway's startCommand runs as a shell command.
# The original image uses ENTRYPOINT ["node", "dist/index.js"] which prevents
# shell-based startup scripts needed to write openclaw.json before launch.
ENTRYPOINT ["/bin/sh", "-c"]

# Default CMD: write config from base64 env var, then start the gateway.
# - OPENCLAW_CONFIG_B64: base64-encoded openclaw.json (set by provisioner)
# - OPENCLAW_GATEWAY_TOKEN: auth token for the gateway API
# - The gateway binds to 0.0.0.0:8080 via config (not env vars, which don't work)
# - exec replaces shell with node so it becomes PID 1 (proper signal handling)
CMD ["mkdir -p /root/.openclaw /data/workspace && echo \"$OPENCLAW_CONFIG_B64\" | base64 -d > /root/.openclaw/openclaw.json && OPENCLAW_STATE_DIR=/root/.openclaw exec node dist/index.js --port 8080 --bind lan --token \"$OPENCLAW_GATEWAY_TOKEN\" --allow-unconfigured"]
