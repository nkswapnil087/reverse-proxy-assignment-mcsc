#!/usr/bin/env python3
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import os

os.chdir(Path(__file__).parent)
class FrontendHandler(SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print(f'[frontend] {self.address_string()} - {fmt % args}', flush=True)

ThreadingHTTPServer(('127.0.0.1', 3000), FrontendHandler).serve_forever()
