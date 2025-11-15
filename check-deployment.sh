#!/bin/bash

# BockVote Deployment Health Check Script

echo "=========================================="
echo "BockVote Deployment Health Check"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_pass() {
    echo -e "${GREEN}[✓]${NC} $1"
}

check_fail() {
    echo -e "${RED}[✗]${NC} $1"
}

check_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check Go installation
echo "1. Checking Go installation..."
if command -v go &> /dev/null; then
    check_pass "Go is installed: $(go version)"
else
    check_fail "Go is not installed"
fi

# Check Flutter installation
echo ""
echo "2. Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    check_pass "Flutter is installed"
else
    check_fail "Flutter is not installed"
fi

# Check Nginx
echo ""
echo "3. Checking Nginx..."
if systemctl is-active --quiet nginx; then
    check_pass "Nginx is running"
else
    check_fail "Nginx is not running"
fi

# Check Backend Service
echo ""
echo "4. Checking Backend Service..."
if systemctl is-active --quiet bockvote-backend; then
    check_pass "Backend service is running"
    
    # Check if backend is responding
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        check_pass "Backend is responding on port 8080"
    else
        check_warn "Backend service running but not responding"
    fi
else
    check_fail "Backend service is not running"
    echo "   Start with: sudo systemctl start bockvote-backend"
fi

# Check Frontend Files
echo ""
echo "5. Checking Frontend Deployment..."
if [ -d "/var/www/bockvote" ]; then
    FILE_COUNT=$(find /var/www/bockvote -type f | wc -l)
    if [ $FILE_COUNT -gt 0 ]; then
        check_pass "Frontend files deployed ($FILE_COUNT files)"
    else
        check_fail "Frontend directory exists but is empty"
    fi
else
    check_fail "Frontend directory not found"
fi

# Check Disk Space
echo ""
echo "6. Checking Disk Space..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -lt 80 ]; then
    check_pass "Disk usage: ${DISK_USAGE}%"
elif [ $DISK_USAGE -lt 90 ]; then
    check_warn "Disk usage: ${DISK_USAGE}% (getting high)"
else
    check_fail "Disk usage: ${DISK_USAGE}% (critically high)"
fi

# Check Memory
echo ""
echo "7. Checking Memory..."
MEMORY_USAGE=$(free | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')
if [ $MEMORY_USAGE -lt 80 ]; then
    check_pass "Memory usage: ${MEMORY_USAGE}%"
elif [ $MEMORY_USAGE -lt 90 ]; then
    check_warn "Memory usage: ${MEMORY_USAGE}% (getting high)"
else
    check_fail "Memory usage: ${MEMORY_USAGE}% (critically high)"
fi

# Check Ports
echo ""
echo "8. Checking Ports..."
if sudo lsof -i :80 > /dev/null 2>&1; then
    check_pass "Port 80 (HTTP) is open"
else
    check_fail "Port 80 (HTTP) is not listening"
fi

if sudo lsof -i :8080 > /dev/null 2>&1; then
    check_pass "Port 8080 (Backend) is open"
else
    check_fail "Port 8080 (Backend) is not listening"
fi

# Get Public IP
echo ""
echo "9. Getting Public IP..."
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
if [ -n "$EC2_IP" ]; then
    check_pass "Public IP: $EC2_IP"
    echo ""
    echo "   Access your app at: http://$EC2_IP"
else
    check_warn "Could not determine public IP"
fi

# Recent Backend Logs
echo ""
echo "10. Recent Backend Logs (last 5 lines)..."
echo "----------------------------------------"
sudo journalctl -u bockvote-backend -n 5 --no-pager
echo "----------------------------------------"

# Summary
echo ""
echo "=========================================="
echo "Health Check Complete"
echo "=========================================="
echo ""
echo "Useful Commands:"
echo "  View backend logs: sudo journalctl -u bockvote-backend -f"
echo "  View nginx logs: sudo tail -f /var/log/nginx/error.log"
echo "  Restart backend: sudo systemctl restart bockvote-backend"
echo "  Restart nginx: sudo systemctl restart nginx"
echo ""
