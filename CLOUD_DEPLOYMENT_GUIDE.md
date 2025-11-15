# Complete Cloud Deployment Guide for BockVote

This guide covers deploying your Flutter voting application with Go backend to AWS EC2.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [AWS EC2 Setup](#aws-ec2-setup)
3. [Server Configuration](#server-configuration)
4. [Backend Deployment (Go)](#backend-deployment-go)
5. [Frontend Deployment (Flutter Web)](#frontend-deployment-flutter-web)
6. [SSL Configuration](#ssl-configuration)
7. [Monitoring & Maintenance](#monitoring--maintenance)

---

## Prerequisites

### Local Machine
- AWS Account with EC2 access
- SSH key pair (.pem file)
- Git installed

### What You'll Deploy
- **Backend**: Go blockchain voting server (projectx)
- **Frontend**: Flutter web application
- **Database**: SQLite (included in Go backend)

---

## AWS EC2 Setup

### Step 1: Launch EC2 Instance

1. **Login to AWS Console** → EC2 Dashboard → Launch Instance

2. **Configure Instance:**
   - **Name**: `bockvote-server`
   - **AMI**: Ubuntu Server 22.04 LTS (64-bit x86)
   - **Instance Type**: `t3.medium` (minimum) or `t3.large` (recommended)
     - 2 vCPUs, 4GB RAM minimum
     - 20GB+ storage (increase to 30GB for safety)
   - **Key Pair**: Create new or use existing
   - **Network Settings**:
     - Allow SSH (port 22) from your IP
     - Allow HTTP (port 80) from anywhere
     - Allow HTTPS (port 443) from anywhere
     - Allow Custom TCP (port 8080) from anywhere (for backend API)

3. **Storage Configuration:**
   - Root volume: 30 GB gp3 (to avoid "no space" errors)

4. **Launch Instance** and wait for it to be running

5. **Note your Public IP**: e.g., `54.123.45.67`

### Step 2: Connect to EC2

```bash
# Set correct permissions for your key
chmod 400 your-key.pem

# Connect via SSH
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

---

## Server Configuration

### Step 3: Update System & Install Dependencies

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y git curl wget unzip build-essential

# Install Nginx (web server)
sudo apt install -y nginx

# Install certbot for SSL (optional, for production)
sudo apt install -y certbot python3-certbot-nginx
```

### Step 4: Install Go (for Backend)

```bash
# Download Go 1.21+
cd /tmp
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz

# Extract and install
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# Add to PATH
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc

# Verify installation
go version
```

### Step 5: Install Flutter (for Frontend)

```bash
# Install Flutter dependencies
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# Download Flutter SDK
cd /opt
sudo git clone https://github.com/flutter/flutter.git -b stable
sudo chown -R $USER:$USER /opt/flutter

# Add to PATH
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Enable web support
flutter config --enable-web

# Verify installation
flutter doctor
```

---

## Backend Deployment (Go)

### Step 6: Clone and Setup Backend

```bash
# Create application directory
mkdir -p ~/apps
cd ~/apps

# Clone your repository
git clone https://github.com/Chinmayabs224/votedapp.git
cd votedapp/projectx

# Copy environment file
cp .env.example .env

# Edit environment variables
nano .env
```

**Configure `.env` file:**
```env
PORT=8080
DB_PATH=./bockvote.db
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your-secure-admin-password
BLOCKCHAIN_NETWORK=testnet
LOG_LEVEL=info
```

### Step 7: Build and Run Backend

```bash
# Install Go dependencies
go mod download

# Build the application
go build -o bockvote-server

# Test run (Ctrl+C to stop)
./bockvote-server
```

### Step 8: Create Systemd Service for Backend

```bash
# Create service file
sudo nano /etc/systemd/system/bockvote-backend.service
```

**Add this content:**
```ini
[Unit]
Description=BockVote Backend Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/apps/votedapp/projectx
ExecStart=/home/ubuntu/apps/votedapp/projectx/bockvote-server
Restart=always
RestartSec=10
Environment="PATH=/usr/local/go/bin:/usr/bin:/bin"

[Install]
WantedBy=multi-user.target
```

**Enable and start the service:**
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable bockvote-backend

# Start the service
sudo systemctl start bockvote-backend

# Check status
sudo systemctl status bockvote-backend

# View logs
sudo journalctl -u bockvote-backend -f
```

---

## Frontend Deployment (Flutter Web)

### Step 9: Build Flutter Web App

```bash
# Navigate to Flutter project root
cd ~/apps/votedapp

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web (production)
flutter build web --release
```

### Step 10: Configure Nginx

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/bockvote
```

**Add this configuration:**
```nginx
server {
    listen 80;
    server_name YOUR_EC2_PUBLIC_IP;  # Replace with your IP or domain

    # Frontend (Flutter Web)
    location / {
        root /var/www/bockvote;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # WebSocket support for real-time features
    location /ws {
        proxy_pass http://localhost:8080/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
```

### Step 11: Deploy Frontend Files

```bash
# Create web directory
sudo mkdir -p /var/www/bockvote

# Copy built files
sudo cp -r ~/apps/votedapp/build/web/* /var/www/bockvote/

# Set permissions
sudo chown -R www-data:www-data /var/www/bockvote
sudo chmod -R 755 /var/www/bockvote

# Enable site
sudo ln -s /etc/nginx/sites-available/bockvote /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## SSL Configuration (Production)

### Step 12: Setup Domain (Optional but Recommended)

1. Purchase a domain (e.g., from Route53, Namecheap)
2. Point A record to your EC2 public IP
3. Wait for DNS propagation (5-30 minutes)

### Step 13: Install SSL Certificate

```bash
# Install SSL certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Follow prompts:
# - Enter email
# - Agree to terms
# - Choose redirect HTTP to HTTPS (option 2)

# Test auto-renewal
sudo certbot renew --dry-run
```

---

## Verification & Testing

### Step 14: Test Your Deployment

```bash
# Check backend is running
curl http://localhost:8080/health

# Check from outside
curl http://YOUR_EC2_PUBLIC_IP/api/health

# Check frontend
# Open browser: http://YOUR_EC2_PUBLIC_IP
```

### Step 15: Test Application Features

1. **Frontend Access**: `http://YOUR_EC2_PUBLIC_IP`
2. **Admin Login**: Use credentials from `.env` file
3. **Create Election**: Test election creation
4. **Cast Vote**: Test voting functionality
5. **View Results**: Check real-time results

---

## Monitoring & Maintenance

### Useful Commands

```bash
# Check backend logs
sudo journalctl -u bockvote-backend -f

# Check Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Restart services
sudo systemctl restart bockvote-backend
sudo systemctl restart nginx

# Check disk space
df -h

# Check memory usage
free -h

# Check running processes
htop  # Install with: sudo apt install htop
```

### Update Application

```bash
# Pull latest changes
cd ~/apps/votedapp
git pull origin master

# Update backend
cd projectx
go build -o bockvote-server
sudo systemctl restart bockvote-backend

# Update frontend
cd ~/apps/votedapp
flutter build web --release
sudo cp -r build/web/* /var/www/bockvote/
sudo systemctl restart nginx
```

### Backup Database

```bash
# Create backup script
nano ~/backup-db.sh
```

**Add:**
```bash
#!/bin/bash
BACKUP_DIR=~/backups
mkdir -p $BACKUP_DIR
DATE=$(date +%Y%m%d_%H%M%S)
cp ~/apps/votedapp/projectx/bockvote.db $BACKUP_DIR/bockvote_$DATE.db
# Keep only last 7 days
find $BACKUP_DIR -name "bockvote_*.db" -mtime +7 -delete
```

```bash
# Make executable
chmod +x ~/backup-db.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add line: 0 2 * * * /home/ubuntu/backup-db.sh
```

---

## Troubleshooting

### Backend Not Starting
```bash
# Check logs
sudo journalctl -u bockvote-backend -n 50

# Check if port is in use
sudo lsof -i :8080

# Verify Go binary
cd ~/apps/votedapp/projectx
./bockvote-server
```

### Frontend Not Loading
```bash
# Check Nginx status
sudo systemctl status nginx

# Check Nginx configuration
sudo nginx -t

# Check file permissions
ls -la /var/www/bockvote
```

### Out of Disk Space
```bash
# Check usage
df -h

# Clean Flutter cache
flutter clean

# Clean system
sudo apt autoremove -y
sudo apt autoclean
```

---

## Security Checklist

- [ ] Change default admin password in `.env`
- [ ] Use strong JWT secret
- [ ] Enable firewall: `sudo ufw enable`
- [ ] Install SSL certificate for HTTPS
- [ ] Regular security updates: `sudo apt update && sudo apt upgrade`
- [ ] Setup automated backups
- [ ] Monitor logs regularly
- [ ] Use SSH keys only (disable password auth)
- [ ] Keep EC2 security groups restrictive

---

## Quick Reference

**Application URLs:**
- Frontend: `http://YOUR_EC2_IP` or `https://yourdomain.com`
- Backend API: `http://YOUR_EC2_IP/api` or `https://yourdomain.com/api`
- Health Check: `http://YOUR_EC2_IP/api/health`

**Service Management:**
```bash
sudo systemctl start|stop|restart|status bockvote-backend
sudo systemctl start|stop|restart|status nginx
```

**Logs:**
```bash
sudo journalctl -u bockvote-backend -f
sudo tail -f /var/log/nginx/error.log
```

---

## Support

For issues or questions:
- Check logs first
- Review this guide
- Check GitHub repository: https://github.com/Chinmayabs224/votedapp

---

**Deployment Complete! 🎉**

Your BockVote application should now be live and accessible from anywhere in the world.
