#!/usr/bin/env python3
"""Corner viewer server: static file serving + an opt-in Python run sandbox.

The sandbox is a separate child process (sandbox.py), started on demand via
/__sandbox/start and never running unless explicitly toggled on from the
front-end. This process kills its sandbox child on exit (atexit/signals) so
the sandbox never outlives the viewer server.
"""
import argparse
import atexit
import functools
import http.server
import json
import os
import signal
import socket
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
from pathlib import Path

_lock = threading.Lock()
_sandbox_proc = None
_sandbox_port = None
_corner_dir = None


def _sandbox_alive():
    return _sandbox_proc is not None and _sandbox_proc.poll() is None


def _start_sandbox():
    global _sandbox_proc
    with _lock:
        if _sandbox_alive():
            return True, True

        script = Path(_corner_dir) / "sandbox.py"
        proc = subprocess.Popen(
            [sys.executable, str(script), "--port", str(_sandbox_port), "--directory", str(_corner_dir)],
        )
        _sandbox_proc = proc

        deadline = time.time() + 5
        while time.time() < deadline:
            if proc.poll() is not None:
                _sandbox_proc = None
                return False, False
            try:
                with socket.create_connection(("127.0.0.1", _sandbox_port), timeout=0.3):
                    return True, False
            except OSError:
                time.sleep(0.15)

        proc.kill()
        _sandbox_proc = None
        return False, False


def _stop_sandbox():
    global _sandbox_proc
    with _lock:
        if _sandbox_proc is None:
            return True, True
        proc = _sandbox_proc
        _sandbox_proc = None
        proc.terminate()
        try:
            proc.wait(timeout=3)
        except subprocess.TimeoutExpired:
            proc.kill()
        return True, False


def _cleanup():
    try:
        _stop_sandbox()
    except Exception:
        pass


def _signal_handler(signum, frame):
    _cleanup()
    sys.exit(0)


class RunHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/__sandbox/status":
            self._send_json(200, {"running": _sandbox_alive()})
            return
        super().do_GET()

    def do_POST(self):
        if self.path == "/__sandbox/start":
            ok, already = _start_sandbox()
            if ok:
                self._send_json(200, {"ok": True, "already": already})
            else:
                self._send_json(503, {"ok": False, "error": "failed_to_start"})
            return

        if self.path == "/__sandbox/stop":
            ok, already = _stop_sandbox()
            self._send_json(200, {"ok": ok, "already": already})
            return

        if self.path == "/__run":
            self._proxy_run()
            return

        self._send_json(404, {"ok": False, "error": "unknown_endpoint"})

    def _proxy_run(self):
        if not _sandbox_alive():
            self._send_json(409, {"ok": False, "error": "sandbox_off"})
            return

        try:
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length) if length > 0 else b"{}"
        except Exception:
            self._send_json(400, {"ok": False, "error": "bad_request"})
            return

        req = urllib.request.Request(
            f"http://127.0.0.1:{_sandbox_port}/run",
            data=body,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                self._send_raw(resp.status, resp.read())
        except urllib.error.HTTPError as e:
            self._send_raw(e.code, e.read())
        except Exception:
            _stop_sandbox()
            self._send_json(409, {"ok": False, "error": "sandbox_off"})

    def _send_json(self, status, obj):
        self._send_raw(status, json.dumps(obj).encode("utf-8"))

    def _send_raw(self, status, raw_bytes):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(raw_bytes)))
        self.end_headers()
        self.wfile.write(raw_bytes)

    def log_message(self, fmt, *args):
        pass


def main():
    global _sandbox_port, _corner_dir

    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--directory", default=os.getcwd())
    parser.add_argument("--bind", default="127.0.0.1")
    args = parser.parse_args()

    _corner_dir = str(Path(args.directory).resolve())
    _sandbox_port = args.port + 1

    atexit.register(_cleanup)
    signal.signal(signal.SIGTERM, _signal_handler)
    signal.signal(signal.SIGINT, _signal_handler)

    handler_cls = functools.partial(RunHandler, directory=_corner_dir)
    http.server.ThreadingHTTPServer.allow_reuse_address = True
    server = http.server.ThreadingHTTPServer((args.bind, args.port), handler_cls)
    server.serve_forever()


if __name__ == "__main__":
    main()
