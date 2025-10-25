# BockVote Deployment Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Development Environment](#development-environment)
3. [Production Deployment](#production-deployment)
4. [Docker Deployment](#docker-deployment)
5. [Security Hardening](#security-hardening)
6. [Monitoring & Logging](#monitoring--logging)
7. [Backup & Recovery](#backup--recovery)

---

## Prerequisites

### System Requirements
- **OS:** Linux (Ubuntu 20.04+), macOS, or Windows
- **RAM:** Minimum 4GB, Recommended 8GB+
- **Storage:** Minimum 20GB free space
- **Network:** Stable internet connection

### Software Requirements
- **Go:** 1.18 or higher
- **Flutter:** 3.0 or higher
- **Node.js:** 16+ (for build tools)
- **Docker:** 20.10+ (optional, for containerized deployment)
- **PostgreSQL:** 13+ (for production database)
- **Nginx:** Latest (for reverse proxy)

---

## Development Environment

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/bockvote.git
cd bockvote
```

### 2. Backend Setup

#### Install Go Dependencies
```bash
cd projectx
go mod download
go mod tidy
```

#### Build Blockchain
```bash
make build
# or
go build -o projectx main.go
```

#### Run Backend Server
```bash
./projectx
# Server will start on http://localhost:9000
```

### 3. Frontend Setup

#### Install Flutter Dependencies
```bash
flutter pub get
```

#### Run Flutter App
```bash
# Web
flutter run -d chrome

# Mobile (Android)
flutter run -d android

# Mobile (iOS)
flutter run -d ios

# Desktop
flutter run -d windows  # or macos, linux
```

### 4. Environment Variables

Create `.env` file in project root:
```env
# Backend
API_PORT=9000
JWT_SECRET=your-super-secret-jwt-key-change-in-production
DATABASE_URL=postgresql://user:password@localhost:5432/bockvote
BLOCKCHAIN_PORT=3000

# Frontend
API_BASE_URL=http://localhost:9000
WS_BASE_URL=ws://localhost:9000/ws
```

---

## Production Deployment

### 1. Server Setup

#### Update System
```bash
sudo apt update && sudo apt upgrade -y
```

#### Install Required Packages
```bash
# Install Go
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Install Nginx
sudo apt install nginx -y

# Install Certbot (for SSL)
sudo apt install certbot python3-certbot-nginx -y
```

### 2. Database Setup

```bash
# Create database
sudo -u postgres psql
CREATE DATABASE bockvote;
CREATE USER bockvote_user WITH ENCRYPTED PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE bockvote TO bockvote_user;
\q
```

### 3. Backend Deployment

#### Build Production Binary
```bash
cd projectx
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bockvote-server main.go
```

#### Create Systemd Service
```bash
sudo nano /etc/systemd/system/bockvote.service
```

Add the following:
```ini
[Unit]
Description=BockVote Blockchain Server
After=network.target

[Service]
Type=simple
User=bockvote
WorkingDirectory=/opt/bockvote
ExecStart=/opt/bockvote/bockvote-server
Restart=always
RestartSec=10
Environment="JWT_SECRET=your-production-secret"
Environment="DATABASE_URL=postgresql://bockvote_user:secure_password@localhost:5432/bockvote"

[Install]
WantedBy=multi-user.target
```

#### Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable bockvote
sudo systemctl start bockvote
sudo systemctl status bockvote
```

### 4. Frontend Deployment

#### Build Flutter Web
```bash
flutter build web --release
```

#### Deploy to Nginx
```bash
sudo cp -r build/web/* /var/www/bockvote/
sudo chown -R www-data:www-data /var/www/bockvote
```

### 5. Nginx Configuration

```bash
sudo nano /etc/nginx/sites-available/bockvote
```

Add the following:
```nginx
# API Server
upstream bockvote_api {
    server localhost:9000;
}

# Frontend
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    root /var/www/bockvote;
    index index.html;

    # Frontend
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API Proxy
    location /api/ {
        proxy_pass http://bockvote_api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # WebSocket Proxy
    location /ws {
        proxy_pass http://bockvote_api/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 86400;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/bockvote /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 6. SSL Certificate

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

---

## Docker Deployment

### 1. Backend Dockerfile

Create `projectx/Dockerfile`:
```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o bockvote-server main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/bockvote-server .

EXPOSE 9000
CMD ["./bockvote-server"]
```

### 2. Frontend Dockerfile

Create `Dockerfile`:
```dockerfile
FROM cirrusci/flutter:stable AS builder

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 3. Docker Compose

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: bockvote
      POSTGRES_USER: bockvote_user
      POSTGRES_PASSWORD: secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build:
      context: ./projectx
      dockerfile: Dockerfile
    environment:
      JWT_SECRET: your-production-secret
      DATABASE_URL: postgresql://bockvote_user:secure_password@postgres:5432/bockvote
    ports:
      - "9000:9000"
    depends_on:
      - postgres
    restart: unless-stopped

  frontend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
```

### 4. Run with Docker Compose

```bash
docker-compose up -d
docker-compose logs -f
```

---

## Security Hardening

### 1. Environment Variables
- Never commit secrets to version control
- Use environment variables or secret management tools
- Rotate JWT secrets regularly

### 2. Database Security
```sql
-- Restrict database access
REVOKE ALL ON DATABASE bockvote FROM PUBLIC;
GRANT CONNECT ON DATABASE bockvote TO bockvote_user;

-- Enable SSL connections
ALTER SYSTEM SET ssl = on;
```

### 3. Firewall Configuration
```bash
# Allow only necessary ports
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
```

### 4. Rate Limiting (Nginx)
```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

location /api/ {
    limit_req zone=api_limit burst=20 nodelay;
    # ... rest of config
}
```

### 5. Security Headers
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

---

## Monitoring & Logging

### 1. Application Logs
```bash
# View backend logs
sudo journalctl -u bockvote -f

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 2. Prometheus Monitoring (Optional)

Install Prometheus:
```bash
docker run -d -p 9090:9090 \
  -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

### 3. Grafana Dashboard (Optional)

```bash
docker run -d -p 3000:3000 grafana/grafana
```

---

## Backup & Recovery

### 1. Database Backup

```bash
# Create backup script
cat > /opt/bockvote/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/bockvote/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup database
pg_dump -U bockvote_user bockvote > $BACKUP_DIR/bockvote_$DATE.sql

# Backup blockchain data
tar -czf $BACKUP_DIR/blockchain_$DATE.tar.gz /opt/bockvote/blockchain

# Keep only last 7 days of backups
find $BACKUP_DIR -type f -mtime +7 -delete
EOF

chmod +x /opt/bockvote/backup.sh
```

### 2. Automated Backups (Cron)

```bash
# Add to crontab
crontab -e

# Add this line (daily backup at 2 AM)
0 2 * * * /opt/bockvote/backup.sh
```

### 3. Restore from Backup

```bash
# Restore database
psql -U bockvote_user bockvote < /opt/bockvote/backups/bockvote_20251023_020000.sql

# Restore blockchain data
tar -xzf /opt/bockvote/backups/blockchain_20251023_020000.tar.gz -C /
```

---

## Troubleshooting

### Backend Not Starting
```bash
# Check logs
sudo journalctl -u bockvote -n 50

# Check port availability
sudo netstat -tulpn | grep 9000

# Restart service
sudo systemctl restart bockvote
```

### Database Connection Issues
```bash
# Test connection
psql -U bockvote_user -d bockvote -h localhost

# Check PostgreSQL status
sudo systemctl status postgresql
```

### WebSocket Connection Failures
- Ensure Nginx WebSocket proxy is configured correctly
- Check firewall rules
- Verify SSL certificate for wss:// connections

---

## Performance Optimization

### 1. Database Indexing
```sql
CREATE INDEX idx_votes_election ON votes(election_id);
CREATE INDEX idx_votes_voter ON votes(voter_id);
CREATE INDEX idx_elections_status ON elections(status);
```

### 2. Nginx Caching
```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m max_size=1g inactive=60m;

location /api/elections {
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
    # ... rest of config
}
```

### 3. Go Performance
```bash
# Build with optimizations
go build -ldflags="-s -w" -o bockvote-server main.go
```

---

## Scaling

### Horizontal Scaling
- Use load balancer (HAProxy, Nginx)
- Deploy multiple backend instances
- Use shared database and blockchain storage

### Vertical Scaling
- Increase server resources (CPU, RAM)
- Optimize database queries
- Use connection pooling

---

## Support

For deployment issues:
1. Check logs first
2. Review documentation
3. Contact DevOps team
4. Create issue in repository

---

**Last Updated:** October 23, 2025
