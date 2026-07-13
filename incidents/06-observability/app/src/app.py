import os
import random
import time

from flask import Flask, Response, jsonify, request
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Gauge,
    Histogram,
    generate_latest,
)


app = Flask(__name__)

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
APP_ENVIRONMENT = os.getenv("APP_ENVIRONMENT", "development")

REQUEST_COUNT = Counter(
    "demo_http_requests_total",
    "Total number of HTTP requests received",
    ["method", "endpoint", "status"],
)

REQUEST_LATENCY = Histogram(
    "demo_http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "endpoint"],
    buckets=(0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 5),
)

ACTIVE_REQUESTS = Gauge(
    "demo_http_active_requests",
    "Number of HTTP requests currently being processed",
)

SIMULATED_ERRORS = Counter(
    "demo_simulated_errors_total",
    "Total number of intentionally simulated errors",
    ["error_type"],
)

APP_INFO = Gauge(
    "demo_application_info",
    "Application information",
    ["version", "environment"],
)

APP_INFO.labels(
    version=APP_VERSION,
    environment=APP_ENVIRONMENT,
).set(1)


def record_request(endpoint: str, status: int, started_at: float) -> None:
    duration = time.time() - started_at

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=endpoint,
        status=str(status),
    ).inc()

    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=endpoint,
    ).observe(duration)


@app.route("/")
def index():
    started_at = time.time()
    ACTIVE_REQUESTS.inc()

    try:
        response = {
            "application": "observability-demo",
            "version": APP_VERSION,
            "environment": APP_ENVIRONMENT,
            "message": "Kubernetes observability lab is running",
        }

        record_request("/", 200, started_at)
        return jsonify(response), 200
    finally:
        ACTIVE_REQUESTS.dec()


@app.route("/health")
def health():
    started_at = time.time()
    ACTIVE_REQUESTS.inc()

    try:
        record_request("/health", 200, started_at)
        return jsonify({"status": "healthy"}), 200
    finally:
        ACTIVE_REQUESTS.dec()


@app.route("/ready")
def ready():
    started_at = time.time()
    ACTIVE_REQUESTS.inc()

    try:
        record_request("/ready", 200, started_at)
        return jsonify({"status": "ready"}), 200
    finally:
        ACTIVE_REQUESTS.dec()


@app.route("/slow")
def slow():
    started_at = time.time()
    ACTIVE_REQUESTS.inc()

    try:
        delay = random.uniform(0.5, 2.0)
        time.sleep(delay)

        record_request("/slow", 200, started_at)

        return jsonify(
            {
                "status": "completed",
                "delay_seconds": round(delay, 2),
            }
        ), 200
    finally:
        ACTIVE_REQUESTS.dec()


@app.route("/error")
def error():
    started_at = time.time()
    ACTIVE_REQUESTS.inc()

    try:
        SIMULATED_ERRORS.labels(error_type="http_500").inc()
        record_request("/error", 500, started_at)

        return jsonify(
            {
                "status": "error",
                "message": "This is an intentional test failure",
            }
        ), 500
    finally:
        ACTIVE_REQUESTS.dec()


@app.route("/metrics")
def metrics():
    return Response(
        generate_latest(),
        mimetype=CONTENT_TYPE_LATEST,
    )


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=8080,
    )
