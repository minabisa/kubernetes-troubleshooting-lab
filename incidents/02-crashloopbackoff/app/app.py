import os
import sys
import time
from http.server import BaseHTTPRequestHandler, HTTPServer


APP_MESSAGE = os.getenv("APP_MESSAGE")


if not APP_MESSAGE:
    print(
        "FATAL: Required environment variable APP_MESSAGE is missing.",
        flush=True,
    )
    sys.exit(1)


class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"healthy\n")
            return

        if self.path == "/ready":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"ready\n")
            return

        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(f"{APP_MESSAGE}\n".encode())


server_address = ("0.0.0.0", 8080)
httpd = HTTPServer(server_address, HealthHandler)

print("Application started successfully on port 8080.", flush=True)
print(f"APP_MESSAGE={APP_MESSAGE}", flush=True)

try:
    httpd.serve_forever()
except KeyboardInterrupt:
    print("Application stopped.", flush=True)
    time.sleep(1)
