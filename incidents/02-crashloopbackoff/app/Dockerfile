FROM python:3.12-alpine

WORKDIR /app

COPY app.py /app/app.py

RUN addgroup -g 10001 -S appgroup \
    && adduser -u 10001 -S appuser -G appgroup \
    && chown -R 10001:10001 /app

USER 10001:10001

EXPOSE 8080

CMD ["python", "/app/app.py"]
