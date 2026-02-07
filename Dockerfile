FROM alpine/openclaw:latest

ENTRYPOINT ["/bin/sh", "-c"]
COPY --chmod=755 boot.sh /boot.sh
CMD ["/boot.sh"]
