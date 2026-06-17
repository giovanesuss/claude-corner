#!/usr/bin/env python3
"""Corner sandbox: a single-purpose process that executes Python scripts on
request. Only exists while the viewer's sandbox toggle is on — spawned by
server.py and killed when toggled off or when server.py itself exits.
"""
import argparse
import http.server
import json
import subprocess
import sys
from pathlib import Path

MAX_OUTPUT = 200_000
PAGES_ROOT = None

RUNNERS = {
    ".py": [sys.executable],
    ".sh": ["bash"],
    ".rb": ["ruby"],
}


def _cap(s):
    if not s:
        return "", False
    if len(s) > MAX_OUTPUT:
        return s[:MAX_OUTPUT], True
    return s, False


class SandboxHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/run":
            self._send_json(404, {"ok": False, "error": "unknown_endpoint"})
            return

        try:
            length = int(self.headers.get("Content-Length", 0))
            raw = self.rfile.read(length) if length > 0 else b"{}"
            data = json.loads(raw)
            rel = data["path"]
        except Exception:
            self._send_json(400, {"ok": False, "error": "bad_request"})
            return

        if not isinstance(rel, str) or ".." in rel.split("/") or rel.startswith("/") or "\x00" in rel:
            self._send_json(403, {"ok": False, "error": "forbidden"})
            return

        target = (PAGES_ROOT / rel).resolve()
        try:
            target.relative_to(PAGES_ROOT)
        except ValueError:
            self._send_json(403, {"ok": False, "error": "forbidden"})
            return

        runner = RUNNERS.get(target.suffix)
        if not runner:
            self._send_json(400, {"ok": False, "error": "invalid_extension"})
            return
        if not target.is_file():
            self._send_json(404, {"ok": False, "error": "not_found"})
            return

        try:
            proc = subprocess.run(
                [*runner, str(target)],
                cwd=str(target.parent),
                capture_output=True,
                text=True,
                timeout=15,
                stdin=subprocess.DEVNULL,
            )
            stdout, t1 = _cap(proc.stdout)
            stderr, t2 = _cap(proc.stderr)
            self._send_json(200, {
                "ok": True,
                "stdout": stdout,
                "stderr": stderr,
                "exit_code": proc.returncode,
                "timed_out": False,
                "truncated": t1 or t2,
            })
        except subprocess.TimeoutExpired as e:
            stdout, t1 = _cap(e.stdout)
            stderr, t2 = _cap(e.stderr)
            self._send_json(200, {
                "ok": True,
                "stdout": stdout,
                "stderr": stderr,
                "exit_code": None,
                "timed_out": True,
                "truncated": t1 or t2,
            })
        except FileNotFoundError:
            self._send_json(400, {"ok": False, "error": "interpreter_not_found"})
        except Exception:
            self._send_json(500, {"ok": False, "error": "execution_failed"})

    def _send_json(self, status, obj):
        body = json.dumps(obj).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass


def main():
    global PAGES_ROOT

    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--directory", required=True)
    args = parser.parse_args()

    PAGES_ROOT = Path(args.directory).resolve() / "pages"

    server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), SandboxHandler)
    server.serve_forever()


if __name__ == "__main__":
    main()
