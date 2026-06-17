
FROM iiidev/iii:latest

ENV III_EXECUTION_CONTEXT=docker
ENV III_HOST_USER_ID=ffab62d4698500e0da6f46324bfc4ca58f57f31fe044c2432bf36995b802418c

WORKDIR /app
COPY config.yaml /app/config.yaml
# iii.lock is engine-managed runtime state (worker registration); the engine
# creates it on first run if missing, so we don't COPY it from the host.
# (Doing so would also fail `docker build` for fresh projects that haven't
# generated one yet, and `iiidev/iii:latest` is distroless so `RUN touch`
# isn't an option.)

# Add 49135 here when enabling iii-worker-manager in config.yaml (Browser SDK / RBAC).
EXPOSE 49134 3111 3112 9464
ENTRYPOINT ["/app/iii"]
CMD ["--config", "/app/config.yaml"]
