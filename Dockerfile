FROM alpine/openclaw:latest

# Override ENTRYPOINT for shell-based startup
ENTRYPOINT ["/bin/sh", "-c"]

# Copy the boot script (--chmod avoids needing RUN chmod as non-root user)
COPY --chmod=755 boot.sh /boot.sh

CMD ["/boot.sh"]
