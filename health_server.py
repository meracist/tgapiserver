#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer

class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(b'{"status":"ok","message":"Telegram Bot API Server Health Check"}')

    def log_message(self, format, *args):
        # Suppress logging to avoid cluttering logs
        return

def run_server():
    server_address = ('', 10000)
    httpd = HTTPServer(server_address, HealthCheckHandler)
    print('Starting health check server on port 10000...')
    httpd.serve_forever()

if __name__ == '__main__':
    run_server()
