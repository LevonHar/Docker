"""Small HTTP service: greetings and text statistics."""

import json
import os
from collections import Counter
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

PORT = int(os.environ.get("PORT", "8080"))


def text_stats(text: str) -> dict:
    words = [w for w in text.split() if w]
    letters = [c.lower() for c in text if c.isalpha()]
    counts = Counter(letters)
    top = counts.most_common(3)
    return {
        "characters": len(text),
        "words": len(words),
        "letters": len(letters),
        "unique_letters": len(counts),
        "top_letters": [{"letter": letter, "count": count} for letter, count in top],
    }


class Handler(BaseHTTPRequestHandler):
    def _send(self, status: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/health":
            self._send(200, {"status": "ok"})
            return
        if parsed.path == "/hello":
            params = parse_qs(parsed.query)
            name = (params.get("name") or ["there"])[0].strip() or "there"
            self._send(200, {"message": f"Hello, {name}."})
            return
        if parsed.path == "/":
            self._send(
                200,
                {
                    "service": "lab3-text",
                    "endpoints": [
                        "GET /health",
                        "GET /hello?name=Ada",
                        "POST /stats  {\"text\": \"...\"}",
                    ],
                },
            )
            return
        self._send(404, {"error": "not found"})

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path != "/stats":
            self._send(404, {"error": "not found"})
            return
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length else b""
        try:
            data = json.loads(raw.decode("utf-8") or "{}")
        except json.JSONDecodeError:
            self._send(400, {"error": "body must be JSON"})
            return
        text = data.get("text")
        if not isinstance(text, str):
            self._send(400, {"error": "field 'text' must be a string"})
            return
        self._send(200, text_stats(text))

    def log_message(self, fmt: str, *args) -> None:
        print(f"{self.address_string()} - {fmt % args}")


def main() -> None:
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"listening on 0.0.0.0:{PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
