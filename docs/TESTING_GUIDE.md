# BockVote Testing Guide

## Table of Contents
1. [Testing Strategy](#testing-strategy)
2. [Unit Tests](#unit-tests)
3. [Integration Tests](#integration-tests)
4. [End-to-End Tests](#end-to-end-tests)
5. [API Testing](#api-testing)
6. [Performance Testing](#performance-testing)
7. [Security Testing](#security-testing)

---

## Testing Strategy

### Test Pyramid
```
        /\
       /E2E\
      /------\
     /  INT   \
    /----------\
   /    UNIT    \
  /--------------\
```

- **Unit Tests (70%):** Test individual functions and classes
- **Integration Tests (20%):** Test component interactions
- **E2E Tests (10%):** Test complete user flows

### Coverage Goals
- **Minimum:** 80% code coverage
- **Target:** 90% code coverage
- **Critical paths:** 100% coverage

---

## Unit Tests

### Running Unit Tests

#### Flutter Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/auth_test.dart

# Run tests in watch mode
flutter test --watch
```

#### Go Tests
```bash
cd projectx

# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run specific package
go test ./api

# Verbose output
go test -v ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Writing Unit Tests

#### Flutter Example
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bockvote/data/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepository repository;

    setUp(() {
      repository = AuthRepository(MockApiService());
    });

    test('login should return token on success', () async {
      final result = await repository.login('test@example.com', 'password');
      expect(result['token'], isNotNull);
    });

    test('login should throw on invalid credentials', () {
      expect(
        () => repository.login('invalid@example.com', 'wrong'),
        throwsException,
      );
    });
  });
}
```

#### Go Example
```go
package api

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestGenerateTokens(t *testing.T) {
    user := &User{
        ID:    "test-123",
        Email: "test@example.com",
        Role:  "voter",
    }

    token, refreshToken, err := generateTokens(user)

    assert.NoError(t, err)
    assert.NotEmpty(t, token)
    assert.NotEmpty(t, refreshToken)
}

func TestAuthMiddleware(t *testing.T) {
    // Test implementation
}
```

---

## Integration Tests

### Running Integration Tests

```bash
# Flutter integration tests
flutter test integration_test/

# With device
flutter test integration_test/ -d chrome
```

### Test Scenarios

1. **Authentication Flow**
   - Register → Login → Access Protected Resource → Logout

2. **Voting Flow**
   - Login → View Elections → Cast Vote → Verify Vote

3. **Admin Flow**
   - Admin Login → Create Election → Manage Users → View Stats

### Example Integration Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete voting flow', (tester) async {
    // 1. Start app
    await tester.pumpWidget(MyApp());
    
    // 2. Login
    await tester.enterText(find.byKey(Key('email')), 'voter@bockvote.com');
    await tester.enterText(find.byKey(Key('password')), 'voter123');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();
    
    // 3. Navigate to elections
    await tester.tap(find.text('Elections'));
    await tester.pumpAndSettle();
    
    // 4. Cast vote
    await tester.tap(find.byKey(Key('election_0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('candidate_0')));
    await tester.tap(find.text('Confirm Vote'));
    await tester.pumpAndSettle();
    
    // 5. Verify success
    expect(find.text('Vote Submitted'), findsOneWidget);
  });
}
```

---

## End-to-End Tests

### Test Cases

#### 1. User Registration & Login
```
✓ User can register with valid credentials
✓ User cannot register with existing email
✓ User can login with correct credentials
✓ User cannot login with wrong password
✓ User session persists after app restart
```

#### 2. Election Management (Admin)
```
✓ Admin can create new election
✓ Admin can add candidates to election
✓ Admin can update election details
✓ Admin can delete election
✓ Admin can view election statistics
```

#### 3. Voting Process
```
✓ User can view active elections
✓ User can view candidate details
✓ User can cast vote for candidate
✓ User cannot vote twice in same election
✓ User receives vote confirmation with tx hash
✓ User can verify vote on blockchain
```

#### 4. Results & Analytics
```
✓ User can view real-time results
✓ Results update automatically via WebSocket
✓ User can export election results
✓ Charts display correctly
```

### Running E2E Tests

```bash
# Run all E2E tests
flutter drive --target=test_driver/app.dart

# Run specific test
flutter drive --target=test_driver/voting_flow.dart
```

---

## API Testing

### Using cURL

#### 1. Authentication
```bash
# Register
curl -X POST http://localhost:9000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "firstName": "Test",
    "lastName": "User"
  }'

# Login
curl -X POST http://localhost:9000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Save token
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 2. Elections
```bash
# Get elections
curl -X GET http://localhost:9000/elections \
  -H "Authorization: Bearer $TOKEN"

# Get election by ID
curl -X GET http://localhost:9000/elections/election-1 \
  -H "Authorization: Bearer $TOKEN"
```

#### 3. Voting
```bash
# Cast vote
curl -X POST http://localhost:9000/vote \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "electionId": "election-1",
    "candidateId": "candidate-1"
  }'

# Get voting history
curl -X GET http://localhost:9000/votes/history \
  -H "Authorization: Bearer $TOKEN"
```

### Using Postman

1. Import collection from `docs/postman_collection.json`
2. Set environment variables:
   - `base_url`: http://localhost:9000
   - `token`: (will be set automatically after login)
3. Run collection tests

### Automated API Tests

Create `test/api_test.sh`:
```bash
#!/bin/bash

BASE_URL="http://localhost:9000"

# Test 1: Register
echo "Test 1: Register user"
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","firstName":"Test","lastName":"User"}')

if echo $REGISTER_RESPONSE | grep -q "token"; then
  echo "✓ Register test passed"
else
  echo "✗ Register test failed"
  exit 1
fi

# Test 2: Login
echo "Test 2: Login user"
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')

if [ ! -z "$TOKEN" ]; then
  echo "✓ Login test passed"
else
  echo "✗ Login test failed"
  exit 1
fi

# Test 3: Get elections
echo "Test 3: Get elections"
ELECTIONS_RESPONSE=$(curl -s -X GET $BASE_URL/elections \
  -H "Authorization: Bearer $TOKEN")

if echo $ELECTIONS_RESPONSE | grep -q "\["; then
  echo "✓ Get elections test passed"
else
  echo "✗ Get elections test failed"
  exit 1
fi

echo "All API tests passed!"
```

Run tests:
```bash
chmod +x test/api_test.sh
./test/api_test.sh
```

---

## Performance Testing

### Load Testing with Apache Bench

```bash
# Test login endpoint
ab -n 1000 -c 10 -p login.json -T application/json \
  http://localhost:9000/auth/login

# Test get elections endpoint
ab -n 1000 -c 10 -H "Authorization: Bearer $TOKEN" \
  http://localhost:9000/elections
```

### Load Testing with k6

Create `test/load_test.js`:
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {
  // Login
  let loginRes = http.post('http://localhost:9000/auth/login', 
    JSON.stringify({
      email: 'voter@bockvote.com',
      password: 'voter123'
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  check(loginRes, {
    'login successful': (r) => r.status === 200,
    'has token': (r) => r.json('token') !== '',
  });

  let token = loginRes.json('token');

  // Get elections
  let electionsRes = http.get('http://localhost:9000/elections', {
    headers: { 'Authorization': `Bearer ${token}` }
  });

  check(electionsRes, {
    'elections retrieved': (r) => r.status === 200,
  });

  sleep(1);
}
```

Run load test:
```bash
k6 run test/load_test.js
```

### Performance Benchmarks

**Target Metrics:**
- API Response Time: < 200ms (p95)
- Vote Submission: < 500ms (p95)
- WebSocket Latency: < 100ms
- Concurrent Users: 10,000+
- Throughput: 1,000 requests/second

---

## Security Testing

### 1. Authentication Tests

```bash
# Test without token
curl -X GET http://localhost:9000/profile
# Expected: 401 Unauthorized

# Test with invalid token
curl -X GET http://localhost:9000/profile \
  -H "Authorization: Bearer invalid_token"
# Expected: 401 Unauthorized

# Test with expired token
curl -X GET http://localhost:9000/profile \
  -H "Authorization: Bearer expired_token"
# Expected: 401 Unauthorized
```

### 2. Authorization Tests

```bash
# Test voter accessing admin endpoint
curl -X GET http://localhost:9000/admin/users \
  -H "Authorization: Bearer $VOTER_TOKEN"
# Expected: 403 Forbidden

# Test admin accessing admin endpoint
curl -X GET http://localhost:9000/admin/users \
  -H "Authorization: Bearer $ADMIN_TOKEN"
# Expected: 200 OK
```

### 3. SQL Injection Tests

```bash
# Test SQL injection in login
curl -X POST http://localhost:9000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@bockvote.com OR 1=1--","password":"anything"}'
# Expected: 401 Unauthorized (not successful login)
```

### 4. XSS Tests

```bash
# Test XSS in election creation
curl -X POST http://localhost:9000/admin/elections \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"<script>alert(\"XSS\")</script>","description":"Test"}'
# Expected: Input should be sanitized
```

### 5. CSRF Tests

- Verify CSRF tokens are required for state-changing operations
- Test cross-origin requests are blocked

### Security Checklist

```
✓ Passwords are hashed with bcrypt
✓ JWT tokens expire after 15 minutes
✓ Refresh tokens expire after 7 days
✓ HTTPS is enforced in production
✓ CORS is properly configured
✓ Rate limiting is enabled
✓ Input validation is implemented
✓ SQL injection protection
✓ XSS protection
✓ CSRF protection
✓ Security headers are set
```

---

## Continuous Integration

### GitHub Actions Workflow

Create `.github/workflows/test.yml`:
```yaml
name: Tests

on: [push, pull_request]

jobs:
  flutter-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2

  go-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v3
        with:
          go-version: '1.21'
      - run: cd projectx && go test -v -cover ./...
```

---

## Test Reports

### Generate Coverage Report

```bash
# Flutter
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Go
cd projectx
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
open coverage.html
```

### Test Metrics

Track these metrics:
- Code coverage percentage
- Number of tests
- Test execution time
- Flaky test rate
- Bug detection rate

---

## Best Practices

1. **Write tests first (TDD)**
2. **Keep tests independent**
3. **Use descriptive test names**
4. **Mock external dependencies**
5. **Test edge cases**
6. **Maintain test data**
7. **Run tests in CI/CD**
8. **Review test coverage regularly**

---

## Troubleshooting

### Tests Failing Locally

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter test

# Check for port conflicts
lsof -i :9000
```

### Flaky Tests

- Add proper waits and timeouts
- Use `pumpAndSettle()` in widget tests
- Avoid time-dependent assertions
- Mock network calls

---

**Last Updated:** October 23, 2025
