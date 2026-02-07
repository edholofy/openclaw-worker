FROM alpine/openclaw:latest

# Override ENTRYPOINT for shell-based startup
ENTRYPOINT ["/bin/sh", "-c"]

# Update OpenClaw to latest version at build time (not runtime)
RUN npm i -g openclaw@latest 2>&1 | tail -5 && openclaw --version

# Copy the boot script (--chmod avoids needing RUN chmod as non-root user)
COPY --chmod=755 boot.sh /boot.sh

CMD ["/boot.sh"]
