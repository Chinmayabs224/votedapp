# ProjectX Blockchain Integration Plugin

## Description
The ProjectX Blockchain Integration Plugin is a comprehensive solution designed to integrate seamlessly with the ProjectX blockchain network, providing high-level API access to blockchain data and functionalities within your applications.

## Installation Instructions
1. Ensure that you have Flutter and Dart installed on your system.
2. Add `blockchain_integration_plugin` as a dependency in your project's `pubspec.yaml`.
3. Run `flutter pub get` to install the package.

## Usage Guidelines
### Import the Plugin
```dart
import 'package:blockchain_integration_plugin/blockchain_integration_plugin.dart';
```

### Initialize the Plugin
```dart
final blockchainPlugin = BlockchainIntegrationPlugin('http://localhost:9000');
```

### Fetch Transactions
```dart
blockchainPlugin.getTransactions().then((transactions) {
  transactions.forEach((transaction) {
    print(transaction.hash);
  });
});
```

### Send a Transaction
```dart
final transaction = BlockchainTransaction(
  hash: 'txHash',
  fromAddress: 'from',
  toAddress: 'to',
  amount: 100.0,
  fee: 1.0,
  signature: 'signature',
  timestamp: DateTime.now().millisecondsSinceEpoch,
  status: TransactionStatus.pending,
  nonce: 1,
);

blockchainPlugin.sendTransaction(transaction);
```

### Real-time Blockchain Updates
```dart
// Get the real-time service from the plugin
final realtimeService = blockchainPlugin.getRealtimeService();

// Listen for blockchain events
realtimeService.eventStream.listen((event) {
  print('${event.timestamp}: ${event.type} - ${event.data}');
});

// Listen for connection status changes
realtimeService.connectionStream.listen((status) {
  print('Connection status: $status');
});

// Initialize the service
realtimeService.initialize();

// Start the service (can be called after initialize or later)
realtimeService.start();

// Stop the service when no longer needed
realtimeService.stop();

// Dispose the plugin when completely done
blockchainPlugin.dispose();
```

## Features List
- Fetch transaction data
- Get the latest blockchain block
- Retrieve network state information
- Submit transactions to the blockchain
- Real-time blockchain updates via WebSocket connection

## System Requirements
- Flutter SDK version 3.3.0 or higher
- Dart SDK version 3.8.1 or higher
- Internet connection to access the blockchain network

## Configuration Options
- `baseUrl`: The base URL for the blockchain API server

## Troubleshooting Tips
- Ensure the blockchain service is running and accessible at the specified `baseUrl`.
- Verify network connectivity if fetching data fails.

## Contribution Guidelines
We welcome contributions! Please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request with a detailed description of your changes.

## License Information
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact Details
For any inquiries or support, please contact the development team at support@projectx.com.

