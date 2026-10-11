FROM python:3.12-alpine

WORKDIR /app

RUN apk add --no-cache curl openssl sqlite

COPY relay_server.py /app/relay_server.py

EXPOSE 9444

VOLUME ["/app/data"]

ENV APNS_KEY_PATH="/app/data/AuthKey.p8"
ENV APNS_BUNDLE_ID="org.example.yihu"

CMD ["python3", "relay_server.py", "--host", "0.0.0.0", "--port", "9444", "--db", "/app/data/relay.db"]
