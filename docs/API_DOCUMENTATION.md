# BockVote API Documentation

## Base URL
```
http://localhost:9000
```

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

### Default Test Users

**Admin User:**
- Email: `admin@bockvote.com`
- Password: `admin123`
- Role: `admin`

**Voter User:**
- Email: `voter@bockvote.com`
- Password: `voter123`
- Role: `voter`

---

## Authentication Endpoints

### Register User
```http
POST /auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-123",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "voter",
    "createdAt": "2025-10-23T10:00:00Z",
    "updatedAt": "2025-10-23T10:00:00Z"
  }
}
```

### Login
```http
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:** Same as Register

### Refresh Token
```http
POST /auth/refresh
```

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:** Same as Register

---

## User Profile Endpoints

### Get Profile
```http
GET /profile
Authorization: Bearer <token>
```

**Response:**
```json
{
  "id": "user-123",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "voter",
  "createdAt": "2025-10-23T10:00:00Z",
  "updatedAt": "2025-10-23T10:00:00Z"
}
```

### Update Profile
```http
PUT /profile
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "firstName": "Jane",
  "lastName": "Smith"
}
```

---

## Election Endpoints

### Get All Elections
```http
GET /elections?status=active
Authorization: Bearer <token>
```

**Query Parameters:**
- `status` (optional): Filter by status (`upcoming`, `active`, `completed`)

**Response:**
```json
[
  {
    "id": "election-1",
    "title": "Presidential Election 2025",
    "description": "Vote for the next president",
    "startDate": "2025-11-01T00:00:00Z",
    "endDate": "2025-11-30T23:59:59Z",
    "status": "active",
    "candidates": [
      {
        "id": "candidate-1",
        "electionId": "election-1",
        "name": "John Smith",
        "party": "Democratic Party",
        "description": "Experienced leader",
        "imageUrl": "https://example.com/image.jpg",
        "voteCount": 150
      }
    ],
    "createdAt": "2025-10-01T10:00:00Z",
    "updatedAt": "2025-10-01T10:00:00Z"
  }
]
```

### Get Election by ID
```http
GET /elections/:id
Authorization: Bearer <token>
```

### Get Election Results
```http
GET /elections/:id/results
Authorization: Bearer <token>
```

**Response:**
```json
{
  "election": { /* election object */ },
  "totalVotes": 500,
  "candidates": [
    {
      "id": "candidate-1",
      "name": "John Smith",
      "voteCount": 300
    },
    {
      "id": "candidate-2",
      "name": "Jane Doe",
      "voteCount": 200
    }
  ]
}
```

---

## Voting Endpoints

### Cast Vote
```http
POST /vote
Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "electionId": "election-1",
  "candidateId": "candidate-1"
}
```

**Response:**
```json
{
  "id": "vote-123",
  "electionId": "election-1",
  "candidateId": "candidate-1",
  "voterId": "user-123",
  "timestamp": "2025-10-23T10:00:00Z",
  "txHash": "0x1234567890abcdef...",
  "verified": true
}
```

### Get Voting History
```http
GET /votes/history
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "vote-123",
    "electionId": "election-1",
    "candidateId": "candidate-1",
    "voterId": "user-123",
    "timestamp": "2025-10-23T10:00:00Z",
    "txHash": "0x1234567890abcdef...",
    "verified": true
  }
]
```

### Verify Vote
```http
GET /votes/:id/verify
Authorization: Bearer <token>
```

**Response:**
```json
{
  "vote": { /* vote object */ },
  "verified": true,
  "txHash": "0x1234567890abcdef...",
  "message": "Vote verified on blockchain"
}
```

---

## Admin Endpoints

All admin endpoints require admin role.

### Get Dashboard Statistics
```http
GET /admin/dashboard/stats
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "totalUsers": 1000,
  "totalElections": 5,
  "totalVotes": 5000,
  "activeElections": 2,
  "blockchainStats": {
    "totalBlocks": 1500,
    "totalTransactions": 5000,
    "networkHashRate": 1000.5,
    "connectedPeers": 3
  }
}
```

### Get All Users
```http
GET /admin/users
Authorization: Bearer <admin-token>
```

### Get User by ID
```http
GET /admin/users/:id
Authorization: Bearer <admin-token>
```

### Update User Role
```http
PUT /admin/users/:id/role
Authorization: Bearer <admin-token>
```

**Request Body:**
```json
{
  "role": "admin"
}
```

### Delete User
```http
DELETE /admin/users/:id
Authorization: Bearer <admin-token>
```

### Create Election
```http
POST /admin/elections
Authorization: Bearer <admin-token>
```

**Request Body:**
```json
{
  "title": "Presidential Election 2025",
  "description": "Vote for the next president",
  "startDate": "2025-11-01T00:00:00Z",
  "endDate": "2025-11-30T23:59:59Z",
  "candidates": [
    {
      "name": "John Smith",
      "party": "Democratic Party",
      "description": "Experienced leader",
      "imageUrl": "https://example.com/image.jpg"
    }
  ]
}
```

### Update Election
```http
PUT /admin/elections/:id
Authorization: Bearer <admin-token>
```

### Delete Election
```http
DELETE /admin/elections/:id
Authorization: Bearer <admin-token>
```

### Export Election Data
```http
GET /admin/elections/:id/export
Authorization: Bearer <admin-token>
```

### Get System Health
```http
GET /admin/health
Authorization: Bearer <admin-token>
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-10-23T10:00:00Z",
  "services": {
    "api": "up",
    "blockchain": "up",
    "database": "up",
    "websocket": "up"
  },
  "blockchain": {
    "height": 1500,
    "connectedPeers": 3
  }
}
```

### Get Audit Logs
```http
GET /admin/audit-logs
Authorization: Bearer <admin-token>
```

---

## Blockchain Endpoints

### Get Block by Hash or Height
```http
GET /block/:hashorid
```

**Example:**
```
GET /block/1
GET /block/0x1234567890abcdef...
```

### Get Transaction by Hash
```http
GET /tx/:hash
```

### Get Latest Block
```http
GET /latest_block
```

### Get All Transactions
```http
GET /transactions
```

### Get Network State
```http
GET /network_state
```

**Response:**
```json
{
  "currentBlockHeight": 1500,
  "latestBlockHash": "0x1234567890abcdef...",
  "totalTransactions": 5000,
  "networkHashRate": 1000.5,
  "connectedPeers": 3,
  "status": "online",
  "avgBlockTime": 5.0,
  "pendingTransactions": 10,
  "totalSupply": 1000000.0,
  "circulatingSupply": 500000.0,
  "timestamp": 1698067200
}
```

### Submit Transaction (Admin Only)
```http
POST /admin/tx
Authorization: Bearer <admin-token>
Content-Type: application/octet-stream
```

---

## WebSocket Endpoint

### Connect to WebSocket
```
ws://localhost:9000/ws
```

**Message Types:**

1. **Ping/Pong**
```json
// Send
{"type": "ping"}

// Receive
{"type": "pong", "data": null}
```

2. **New Transaction**
```json
{
  "type": "transaction",
  "data": {
    "hash": "0x1234...",
    "from": "0xabcd...",
    "to": "0xefgh...",
    "amount": 100.0,
    "fee": 0.1,
    "timestamp": 1698067200,
    "signature": "0x5678...",
    "status": "pending",
    "nonce": 1
  }
}
```

3. **New Block**
```json
{
  "type": "block",
  "data": {
    "hash": "0x1234...",
    "previousHash": "0xabcd...",
    "height": 1500,
    "timestamp": 1698067200,
    "validator": "0xefgh...",
    "transactions": [ /* array of transactions */ ],
    "merkleRoot": "0x5678...",
    "nonce": 0,
    "difficulty": 0.0,
    "gasUsed": 0,
    "gasLimit": 0,
    "status": "confirmed"
  }
}
```

4. **Network State Update**
```json
{
  "type": "network_state",
  "data": {
    "currentBlockHeight": 1500,
    "latestBlockHash": "0x1234...",
    "totalTransactions": 5000,
    "networkHashRate": 1000.5,
    "connectedPeers": 3,
    "status": "online",
    "avgBlockTime": 5.0,
    "pendingTransactions": 10,
    "totalSupply": 1000000.0,
    "circulatingSupply": 500000.0,
    "timestamp": 1698067200
  }
}
```

5. **Vote Cast**
```json
{
  "type": "vote",
  "data": {
    "id": "vote-123",
    "electionId": "election-1",
    "candidateId": "candidate-1",
    "voterId": "user-123",
    "timestamp": "2025-10-23T10:00:00Z",
    "txHash": "0x1234...",
    "verified": true
  }
}
```

---

## Error Responses

All errors follow this format:

```json
{
  "error": "Error message description"
}
```

**Common HTTP Status Codes:**
- `200 OK` - Success
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource already exists
- `500 Internal Server Error` - Server error

---

## Rate Limiting

Rate limiting is applied to prevent abuse:
- 100 requests per minute per IP address
- 1000 requests per hour per authenticated user

---

## Security

### JWT Token Expiration
- Access Token: 15 minutes
- Refresh Token: 7 days

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number

### CORS
CORS is enabled for all origins in development. In production, configure allowed origins.

---

## Testing with cURL

### Login Example
```bash
curl -X POST http://localhost:9000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"voter@bockvote.com","password":"voter123"}'
```

### Get Elections Example
```bash
curl -X GET http://localhost:9000/elections \
  -H "Authorization: Bearer <your-token>"
```

### Cast Vote Example
```bash
curl -X POST http://localhost:9000/vote \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{"electionId":"election-1","candidateId":"candidate-1"}'
```

---

## Support

For issues or questions, please contact the development team or create an issue in the repository.
