FROM alpine/openclaw:latest

# Override ENTRYPOINT so Railway's startCommand runs as a shell command.
# The original image uses ENTRYPOINT ["node", "dist/index.js"] which prevents
# shell-based startup scripts needed to write openclaw.json before launch.
ENTRYPOINT ["/bin/sh", "-c"]

# Copy the boot script (--chmod avoids needing RUN chmod as non-root user)
COPY --chmod=755 boot.sh /boot.sh

CMD ["/boot.sh"]
