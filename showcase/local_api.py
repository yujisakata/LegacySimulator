"""Legacy Evolution デモ専用のローカル検証 API。

登録済みの PowerShell テストだけを実行し、任意のコマンドやパスは
受け付けない。127.0.0.1 だけで待ち受ける。
"""

from __future__ import annotations

import json
import shutil
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


HOST = "127.0.0.1"
PORT = 4311
SHOWCASE_ROOT = Path(__file__).resolve().parent
REPOSITORY_ROOT = SHOWCASE_ROOT.parent
TESTS = {
    "v1": ("V1 基準19件", REPOSITORY_ROOT / "test/v01/scripts/run-tests.ps1"),
    "v2": ("V2 互換＋特約53件", REPOSITORY_ROOT / "test/v02/scripts/run-tests.ps1"),
    "regression": (
        "V1～V3 回帰",
        REPOSITORY_ROOT / "test/v03/scripts/run-regression.ps1",
    ),
    "all": (
        "V1～V10 全Version",
        REPOSITORY_ROOT / "test/run-all-versions.ps1",
    ),
}
ALLOWED_ORIGINS = {"http://127.0.0.1:3000", "http://localhost:3000"}
TEST_LOCK = threading.Lock()


class DemoHandler(BaseHTTPRequestHandler):
    server_version = "LegacyEvolutionDemo/1.0"

    def _origin(self) -> str:
        origin = self.headers.get("Origin", "")
        return origin if origin in ALLOWED_ORIGINS else "http://127.0.0.1:3000"

    def _send_json(self, status: int, body: dict[str, object]) -> None:
        payload = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Access-Control-Allow-Origin", self._origin())
        self.send_header("Vary", "Origin")
        self.end_headers()
        self.wfile.write(payload)

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", self._origin())
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self) -> None:
        if self.path != "/health":
            self._send_json(404, {"ok": False, "message": "Not found"})
            return
        self._send_json(
            200,
            {
                "ok": True,
                "service": "Legacy Evolution local verification API",
                "tests": list(TESTS),
            },
        )

    def do_POST(self) -> None:
        if self.path != "/api/run-test":
            self._send_json(404, {"ok": False, "message": "Not found"})
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length < 1 or length > 1024:
                raise ValueError("Invalid request size")
            request = json.loads(self.rfile.read(length).decode("utf-8"))
            test_id = request.get("id")
        except (ValueError, json.JSONDecodeError, UnicodeDecodeError):
            self._send_json(400, {"ok": False, "message": "Invalid JSON"})
            return

        if test_id not in TESTS:
            self._send_json(400, {"ok": False, "message": "Unknown test id"})
            return
        if not TEST_LOCK.acquire(blocking=False):
            self._send_json(409, {"ok": False, "message": "別のテストを実行中です。"})
            return

        label, script_path = TESTS[test_id]
        started = time.monotonic()
        try:
            pwsh = shutil.which("pwsh")
            if not pwsh:
                raise FileNotFoundError("PowerShell 7 (pwsh) が見つかりません。")
            if not script_path.is_file():
                raise FileNotFoundError(f"登録済みテストが見つかりません: {script_path}")
            completed = subprocess.run(
                [pwsh, "-NoLogo", "-NoProfile", "-File", str(script_path)],
                cwd=REPOSITORY_ROOT,
                capture_output=True,
                text=True,
                # Windows版PowerShellがリダイレクト時に使う日本語コードページ。
                encoding="cp932",
                errors="replace",
                timeout=180,
                check=False,
            )
            output = (completed.stdout + completed.stderr).strip()
            self._send_json(
                200,
                {
                    "ok": completed.returncode == 0,
                    "exitCode": completed.returncode,
                    "output": output or "出力はありません。",
                    "elapsedSeconds": round(time.monotonic() - started, 1),
                    "label": label,
                },
            )
        except subprocess.TimeoutExpired as error:
            output = ((error.stdout or "") + (error.stderr or "")).strip()
            self._send_json(
                200,
                {
                    "ok": False,
                    "exitCode": -1,
                    "output": output + "\n180秒で実行を終了しました。",
                    "elapsedSeconds": 180.0,
                    "label": label,
                },
            )
        except (FileNotFoundError, OSError) as error:
            self._send_json(
                200,
                {
                    "ok": False,
                    "exitCode": -1,
                    "output": str(error),
                    "elapsedSeconds": round(time.monotonic() - started, 1),
                    "label": label,
                },
            )
        finally:
            TEST_LOCK.release()

    def log_message(self, format_string: str, *args: object) -> None:
        print(f"[local-api] {self.address_string()} {format_string % args}")


if __name__ == "__main__":
    print(f"Legacy Evolution local API: http://{HOST}:{PORT}")
    ThreadingHTTPServer((HOST, PORT), DemoHandler).serve_forever()
