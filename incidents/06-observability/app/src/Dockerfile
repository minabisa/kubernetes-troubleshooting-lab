FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    --requirement requirements.txt

COPY app.py .

RUN addgroup \
      -g 10001 \
      -S appgroup \
    && adduser \
      -u 10001 \
      -S appuser \
      -G appgroup \
    && chown \
      -R 10001:10001 \
      /app

USER 10001:10001

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "2", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
