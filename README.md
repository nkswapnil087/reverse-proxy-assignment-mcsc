# NGINX Reverse Proxy Assignment

This Linux project demonstrates how a client request travels through an NGINX reverse proxy to separate frontend and backend services. The backend records successful API requests in MySQL.

## Architecture

```text
Client -> NGINX :8080
             |-- /     -> frontend 127.0.0.1:3000
             |-- /api  -> backend  127.0.0.1:5000 -> MySQL 127.0.0.1:3306
```

NGINX is the public entry point. The frontend and backend are local application services, and the backend writes each successful `/api` request to the MySQL `requests` table.

## Project structure

```text
frontend/          Static HTML, CSS, JavaScript, and frontend server
backend/           Python JSON API server
nginx/             NGINX reverse-proxy configuration
database/          MySQL schema
run.sh             Starts MySQL setup, applications, and NGINX
stop.sh            Stops the project applications and NGINX
setup-nginx.sh     Checks for the system NGINX installation
setup-mysql.sh     Creates the database, user, and table
requirements.txt   Python dependency list
```

## Requirements

- Linux
- NGINX
- MySQL server and client, listening on `127.0.0.1:3306`
- Python 3
- PyMySQL

Install packages on Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y nginx mysql-server python3-pymysql
```

## Configuration and setup

Copy the example environment file and set a local password. Do not commit `.env`.

```bash
cp .env.example .env
editor .env
```

Start MySQL before running the project. If root uses socket authentication, set `MYSQL_SOCKET` in `.env` or run `setup-mysql.sh` with the appropriate administrator settings.

```bash
sudo systemctl enable --now mysql
./setup-nginx.sh
./run.sh
```

The setup script creates the `reverse_proxy_assignment` database, the `requests` table, and the application user from `MYSQL_PASSWORD`.

## Test

Open the frontend:

```text
http://127.0.0.1:8080/
```

Test the API through NGINX:

```bash
curl http://127.0.0.1:8080/api
```

Test the backend directly:

```bash
curl http://127.0.0.1:5000/api
```

Inspect database records:

```bash
MYSQL_PWD="$MYSQL_PASSWORD" mysql -h127.0.0.1 -P3306 -uassignment_user -D reverse_proxy_assignment -e 'SELECT * FROM requests;'
```

## Request flow

The client connects only to NGINX on port `8080`. NGINX sends `/` requests to the frontend on port `3000`. It sends `/api` requests to the backend on port `5000`. The backend inserts a row into MySQL and returns the current request count as JSON.

## Stop

```bash
./stop.sh
```

Runtime logs, PID files, database data, local binaries, and `.env` are intentionally excluded by `.gitignore`.
