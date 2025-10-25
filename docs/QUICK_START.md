# BockVote Quick Start Guide

Get BockVote up and running in 5 minutes!

## Prerequisites

- Go 1.18+
- Flutter 3.0+
- Git

## Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/bockvote.git
cd bockvote
```

## Step 2: Start Backend

```bash
# Navigate to backend
cd projectx

# Install dependencies
go mod download

# Build and run
go build -o bockvote-server main.go
./bockvote-server
```

Backend will start on `http://localhost:9000`

## Step 3: Start Frontend

Open a new terminal:

```bash
# Navigate to project root
cd bockvote

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Or run on mobile
flutter run -d android  # or ios
```

## Step 4: Login

Use one of the default test accounts:

**Admin Account:**
- Email: `admin@bockvote.com`
- Password: `admin123`

**Voter Account:**
- Email: `voter@bockvote.com`
- Password: `voter123`

## Step 5: Test the System

### As Admin:
1. Login with admin credentials
2. Navigate to Admin Panel
3. Create a new election
4. Add candidates
5. Set start/end dates
6. Publish election

### As Voter:
1. Login with voter credentials
2. View active elections
3. Select an election
4. Choose a candidate
5. Cast your vote
6. Verify vote on blockchain

## API Testing

### Test with cURL

```bash
# Login
curl -X POST http://localhost:9000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"voter@bockvote.com","password":"voter123"}'

# Save the token from response
TOKEN="your-token-here"

# Get elections
curl -X GET http://localhost:9000/elections \
  -H "Authorization: Bearer $TOKEN"

# Cast vote
curl -X POST http://localhost:9000/vote \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"electionId":"election-1","candidateId":"candidate-1"}'
```

## WebSocket Testing

Connect to WebSocket for real-time updates:

```javascript
const ws = new WebSocket('ws://localhost:9000/ws');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Received:', data);
};

// Send ping
ws.send(JSON.stringify({ type: 'ping' }));
```

## Verify Installation

### Check Backend Health

```bash
curl http://localhost:9000/network_state
```

Expected response:
```json
{
  "currentBlockHeight": 0,
  "status": "online",
  "timestamp": 1698067200
}
```

### Check Frontend

Open browser to `http://localhost:PORT` (Flutter will show the port)

You should see the BockVote login screen.

## Common Issues

### Port Already in Use

```bash
# Check what's using port 9000
lsof -i :9000

# Kill the process
kill -9 <PID>
```

### Go Dependencies Error

```bash
cd projectx
go mod tidy
go mod download
```

### Flutter Dependencies Error

```bash
flutter clean
flutter pub get
```

## Next Steps

- Read [API Documentation](API_DOCUMENTATION.md)
- Review [Testing Guide](TESTING_GUIDE.md)
- Check [Deployment Guide](DEPLOYMENT_GUIDE.md)
- Explore the codebase

## Project Structure

```
bockvote/
├── projectx/              # Go backend
│   ├── api/              # REST API & WebSocket
│   ├── core/             # Blockchain core
│   └── main.go           # Entry point
├── lib/                  # Flutter frontend
│   ├── core/             # Core utilities
│   ├── data/             # Data layer
│   ├── features/         # Feature modules
│   └── main.dart         # Entry point
├── docs/                 # Documentation
└── test/                 # Tests
```

## Development Workflow

1. **Backend Development:**
   ```bash
   cd projectx
   go run main.go
   ```

2. **Frontend Development:**
   ```bash
   flutter run -d chrome
   ```

3. **Run Tests:**
   ```bash
   # Backend
   cd projectx && go test ./...
   
   # Frontend
   flutter test
   ```

4. **Build for Production:**
   ```bash
   # Backend
   cd projectx && go build -o bockvote-server
   
   # Frontend
   flutter build web --release
   ```

## Support

- **Documentation:** Check `docs/` folder
- **Issues:** Create issue on GitHub
- **API Reference:** See `docs/API_DOCUMENTATION.md`

## Default Credentials Summary

| Role  | Email                  | Password  |
|-------|------------------------|-----------|
| Admin | admin@bockvote.com     | admin123  |
| Voter | voter@bockvote.com     | voter123  |

**⚠️ Change these credentials in production!**

---

**Ready to vote? Let's go! 🗳️**
