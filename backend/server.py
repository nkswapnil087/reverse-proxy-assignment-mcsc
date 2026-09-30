#!/usr/bin/env python3
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from datetime import datetime, timezone

import pymysql

DB_CONFIG = {
    'host': os.getenv('MYSQL_HOST', '127.0.0.1'),
    'port': int(os.getenv('MYSQL_PORT', '3306')),
    'user': os.getenv('MYSQL_USER', 'assignment_user'),
    'password': os.getenv('MYSQL_PASSWORD'),
    'database': os.getenv('MYSQL_DATABASE', 'reverse_proxy_assignment'),
    'autocommit': True,
    'cursorclass': pymysql.cursors.DictCursor,
}

if not DB_CONFIG['password']:
    raise RuntimeError('MYSQL_PASSWORD is required. Copy .env.example to .env and set it.')

def record_request(path):
    connection = pymysql.connect(**DB_CONFIG)
    try:
        with connection.cursor() as cursor:
            cursor.execute('INSERT INTO requests(path) VALUES (%s)', (path,))
            cursor.execute('SELECT COUNT(*) AS request_count FROM requests')
            return cursor.fetchone()['request_count']
    finally:
        connection.close()

class APIHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.rstrip('/') != '/api':
            self.send_error(404, 'Use GET /api')
            return
        request_count = record_request(self.path)
        payload = {
            'message': 'Backend reached through the NGINX reverse proxy.',
            'service': 'backend',
            'backend_port': 5000,
            'database': 'MySQL: reverse_proxy_assignment.requests',
            'database_request_count': request_count,
            'request_path': self.path,
            'time_utc': datetime.now(timezone.utc).isoformat(),
        }
        body = json.dumps(payload, indent=2).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(f'[backend] {self.address_string()} - {fmt % args}', flush=True)

ThreadingHTTPServer(('127.0.0.1', 5000), APIHandler).serve_forever()
