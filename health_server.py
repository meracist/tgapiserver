import http.server
import socketserver

PORT = 10000

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status":"ok","message":"Telegram Bot API Health Check"}')
        else:
            self.send_response(404)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(b'Not Found')

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("Health check server running at port", PORT)
    httpd.serve_forever()
