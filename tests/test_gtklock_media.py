import base64
import os
import re
import shutil
import subprocess
import tempfile
import threading
import time
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ["gtk+-3.0", "gmodule-export-2.0", "playerctl", "libsoup-3.0"]
PNG = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j5qkAAAAASUVORK5CYII="
)


class ArtworkServer(BaseHTTPRequestHandler):
    def log_message(self, *_args):
        pass

    def do_GET(self):
        body = b"x" * (9 * 1024 * 1024) if self.path == "/large" else PNG
        self.send_response(404 if self.path == "/missing" else 200)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        try:
            self.wfile.write(body[:1])
            self.wfile.flush()
            if self.path in {"/slow", "/timeout"}:
                time.sleep(12 if self.path == "/timeout" else 1)
            self.wfile.write(body[1:])
        except (BrokenPipeError, ConnectionResetError):
            pass


class GtklockMediaTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        compiler = shutil.which("cc")
        pkg_config = shutil.which("pkg-config")
        if not compiler or not pkg_config:
            raise unittest.SkipTest("requires a C compiler and pkg-config")
        flags = subprocess.run(  # noqa: S603
            [pkg_config, "--cflags", "--libs", *PACKAGES], text=True, capture_output=True, check=False,
        )
        if flags.returncode:
            raise unittest.SkipTest("requires GTK, Playerctl and libsoup development files")
        cls.work = tempfile.TemporaryDirectory(prefix="gtklock-media-test-")
        cls.addClassCleanup(cls.work.cleanup)
        cls.binary = Path(cls.work.name) / "media-test"
        build = subprocess.run(  # noqa: S603
            [compiler, "-o", str(cls.binary), str(ROOT / "tests/gtklock_media.c"), *flags.stdout.split()],
            text=True, capture_output=True, check=False,
        )
        if build.returncode:
            raise AssertionError(build.stdout + build.stderr)
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), ArtworkServer)
        cls.addClassCleanup(cls.server.server_close)
        cls.addClassCleanup(cls.server.shutdown)
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()

    def run_artwork(self, path, *, duration=1500, mode="load"):
        with tempfile.TemporaryDirectory(prefix="gtklock-artwork-") as directory:
            if path.startswith("/"):
                url = f"http://127.0.0.1:{self.server.server_port}{path}"
            else:
                fixture = Path(directory) / "art.png"
                fixture.write_bytes(PNG)
                url = fixture.as_uri()
            result = subprocess.run(  # noqa: S603
                [str(self.binary), url, str(duration), mode],
                env=os.environ | {"XDG_CACHE_HOME": directory}, text=True, capture_output=True,
                timeout=duration / 1000 + 5, check=False,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            match = re.search(r"cache_files=(\d+)", result.stdout)
            self.assertIsNotNone(match, result.stdout)
            return int(match[1])

    def test_slow_response_does_not_block_the_main_loop(self):
        self.assertEqual(self.run_artwork("/slow"), 1)

    def test_oversized_response_is_not_cached(self):
        self.assertEqual(self.run_artwork("/large"), 0)

    def test_http_error_is_not_cached(self):
        self.assertEqual(self.run_artwork("/missing"), 0)

    def test_cancelled_response_is_not_cached(self):
        self.assertEqual(self.run_artwork("/slow", duration=500, mode="cancel"), 0)

    def test_destroyed_window_does_not_leave_a_callback_using_its_memory(self):
        self.assertEqual(self.run_artwork("/slow", duration=500, mode="destroy"), 0)

    def test_stalled_response_times_out(self):
        self.assertEqual(self.run_artwork("/timeout", duration=11000), 0)

    def test_local_file_is_cached(self):
        self.assertEqual(self.run_artwork("file"), 1)


if __name__ == "__main__":
    unittest.main()
