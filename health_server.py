import http.server
import socketserver

PORT = 10000

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"ok","message":"Telegram Bot API Health Check"}')

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("Health check server running at port", PORT)
    httpd.serve_forever()
