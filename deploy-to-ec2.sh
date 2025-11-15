#!/bin/bash

# BockVote EC2 Deployment Script
# Run this script on your EC2 instance after connecting via SSH

set -e  # Exit on error

echo "=========================================="
echo "BockVote EC2 Deployment Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Please do not run as root. Run as ubuntu user."
    exit 1
fi

# Step 1: Update System
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Step 2: Install Essential Tools
print_status "Installing essential tools..."
sudo apt install -y git curl wget unzip build-essential nginx

# Step 3: Install Go
print_status "Installing Go..."
if ! command -v go &> /dev/null; then
    cd /tmp
    wget -q https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
    
    # Add to PATH
    if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
    fi
    
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
    
    print_status "Go installed: $(go version)"
else
    print_status "Go already installed: $(go version)"
fi

# Step 4: Install Flutter
print_status "Installing Flutter..."
if [ ! -d "/opt/flutter" ]; then
    sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
    
    cd /opt
    sudo git clone https://github.com/flutter/flutter.git -b stable
    sudo chown -R $USER:$USER /opt/flutter
    
    # Add to PATH
    if ! grep -q "/opt/flutter/bin" ~/.bashrc; then
        echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
    fi
    
    export PATH="$PATH:/opt/flutter/bin"
    
    flutter config --enable-web
    print_status "Flutter installed"
else
    print_status "Flutter already installed"
fi

# Step 5: Clone Repository
print_status "Cloning repository..."
mkdir -p ~/apps
cd ~/apps

if [ -d "votedapp" ]; then
    print_warning "Repository already exists. Pulling latest changes..."
    cd votedapp
    git pull origin master
else
    git clone https://github.com/Chinmayabs224/votedapp.git
    cd votedapp
fi

# Step 6: Setup Backend
print_status "Setting up backend..."
cd ~/apps/votedapp/projectx

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    cp .env.example .env
    print_warning "Created .env file. Please edit it with your configuration:"
    print_warning "nano ~/apps/votedapp/projectx/.env"
fi

# Build backend
print_status "Building Go backend..."
go mod download
go build -o bockvote-server

# Create systemd service
print_status "Creating systemd service..."
sudo tee /etc/systemd/system/bockvote-backend.service > /dev/null <<EOF
[Unit]
Description=BockVote Backend Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/apps/votedapp/projectx
ExecStart=$HOME/apps/votedapp/projectx/bockvote-server
Restart=always
RestartSec=10
Environment="PATH=/usr/local/go/bin:/usr/bin:/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable bockvote-backend
sudo systemctl start bockvote-backend

# Step 7: Build Frontend
print_status "Building Flutter frontend..."
cd ~/apps/votedapp

# Create asset directories if they don't exist
mkdir -p assets/images assets/icons assets/animations

# Clean and build
flutter clean
flutter pub get
flutter build web --release

# Step 8: Deploy Frontend
print_status "Deploying frontend to Nginx..."
sudo mkdir -p /var/www/bockvote
sudo cp -r build/web/* /var/www/bockvote/
sudo chown -R www-data:www-data /var/www/bockvote
sudo chmod -R 755 /var/www/bockvote

# Step 9: Configure Nginx
print_status "Configuring Nginx..."

# Get EC2 public IP
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

sudo tee /etc/nginx/sites-available/bockvote > /dev/null <<EOF
server {
    listen 80;
    server_name $EC2_IP;

    # Frontend (Flutter Web)
    location / {
        root /var/www/bockvote;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # WebSocket support
    location /ws {
        proxy_pass http://localhost:8080/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/bockvote /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
sudo nginx -t
sudo systemctl restart nginx

# Step 10: Setup Firewall (optional)
print_status "Configuring firewall..."
sudo ufw --force enable
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp

echo ""
echo "=========================================="
print_status "Deployment Complete!"
echo "=========================================="
echo ""
echo "Your application is now running at:"
echo "  Frontend: http://$EC2_IP"
echo "  Backend API: http://$EC2_IP/api"
echo ""
echo "Service Management:"
echo "  Backend: sudo systemctl status bockvote-backend"
echo "  Nginx: sudo systemctl status nginx"
echo ""
echo "View Logs:"
echo "  Backend: sudo journalctl -u bockvote-backend -f"
echo "  Nginx: sudo tail -f /var/log/nginx/error.log"
echo ""
print_warning "IMPORTANT: Edit your .env file with secure credentials:"
echo "  nano ~/apps/votedapp/projectx/.env"
echo "  Then restart: sudo systemctl restart bockvote-backend"
echo ""
print_warning "For production, setup SSL with: sudo certbot --nginx"
echo ""
