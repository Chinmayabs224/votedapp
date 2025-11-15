# BockVote Cloud Deployment - Quick Start

This folder contains everything you need to deploy BockVote to AWS EC2.

## 📁 Files

1. **CLOUD_DEPLOYMENT_GUIDE.md** - Complete step-by-step deployment guide
2. **deploy-to-ec2.sh** - Automated deployment script
3. **check-deployment.sh** - Health check and troubleshooting script

## 🚀 Quick Deployment (Automated)

### Step 1: Launch EC2 Instance
- **AMI**: Ubuntu 22.04 LTS
- **Instance Type**: t3.medium or larger
- **Storage**: 30 GB
- **Security Group**: Allow ports 22, 80, 443, 8080

### Step 2: Connect to EC2
```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_IP
```

### Step 3: Run Deployment Script
```bash
# Download the deployment script
curl -O https://raw.githubusercontent.com/Chinmayabs224/votedapp/master/deploy-to-ec2.sh

# Make it executable
chmod +x deploy-to-ec2.sh

# Run it
./deploy-to-ec2.sh
```

### Step 4: Configure Environment
```bash
# Edit the .env file with your settings
nano ~/apps/votedapp/projectx/.env

# Restart backend
sudo systemctl restart bockvote-backend
```

### Step 5: Access Your App
```
http://YOUR_EC2_IP
```

## 🔍 Health Check

Run the health check script anytime:
```bash
# Download health check script
curl -O https://raw.githubusercontent.com/Chinmayabs224/votedapp/master/check-deployment.sh

# Make it executable
chmod +x check-deployment.sh

# Run it
./check-deployment.sh
```

## 📖 Manual Deployment

If you prefer manual deployment or need to troubleshoot, follow the complete guide:
- Read **CLOUD_DEPLOYMENT_GUIDE.md** for detailed instructions

## 🛠️ Common Commands

### Service Management
```bash
# Check backend status
sudo systemctl status bockvote-backend

# Restart backend
sudo systemctl restart bockvote-backend

# View backend logs
sudo journalctl -u bockvote-backend -f

# Restart Nginx
sudo systemctl restart nginx
```

### Update Application
```bash
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
```

### Troubleshooting
```bash
# Check if backend is responding
curl http://localhost:8080/health

# Check disk space
df -h

# Check memory
free -h

# View Nginx error logs
sudo tail -f /var/log/nginx/error.log
```

## 🔒 Security Checklist

After deployment:
- [ ] Change admin password in `.env`
- [ ] Use strong JWT secret
- [ ] Setup SSL certificate: `sudo certbot --nginx`
- [ ] Enable firewall: `sudo ufw enable`
- [ ] Setup automated backups
- [ ] Regular security updates

## 📞 Support

- **Full Guide**: See CLOUD_DEPLOYMENT_GUIDE.md
- **GitHub**: https://github.com/Chinmayabs224/votedapp
- **Issues**: Check logs first, then review troubleshooting section

## ⚡ Quick Reference

**URLs:**
- Frontend: `http://YOUR_EC2_IP`
- Backend API: `http://YOUR_EC2_IP/api`
- Health Check: `http://YOUR_EC2_IP/api/health`

**Default Credentials:**
- Check your `.env` file for admin credentials
- Default: admin/admin (CHANGE THIS!)

---

**Happy Deploying! 🎉**
