import 'package:flutter_test/flutter_test.dart';
import 'package:bockvote/data/repositories/blockchain_repository.dart';

void main() {
  group('Blockchain Tests', () {
    late BlockchainRepository blockchainRepository;

    setUp(() {
      blockchainRepository = BlockchainRepository();
    });

    test('Get latest block should return block data', () async {
      // Act
      final block = await blockchainRepository.getLatestBlock();

      // Assert
      expect(block, isNotNull);
      expect(block['hash'], isNotNull);
      expect(block['height'], isNotNull);
    });

    test('Get block by height should return correct block', () async {
      // Arrange
      const height = 1;

      // Act
      final block = await blockchainRepository.getBlockByHeight(height);

      // Assert
      expect(block, isNotNull);
      expect(block['height'], equals(height));
    });

    test('Get transaction by hash should return transaction', () async {
      // Arrange
      const txHash = '0x1234567890abcdef';

      // Act
      final tx = await blockchainRepository.getTransactionByHash(txHash);

      // Assert
      expect(tx, isNotNull);
      expect(tx['hash'], equals(txHash));
    });

    test('Get network state should return blockchain status', () async {
      // Act
      final state = await blockchainRepository.getNetworkState();

      // Assert
      expect(state, isNotNull);
      expect(state['currentBlockHeight'], isNotNull);
      expect(state['status'], equals('online'));
    });

    test('WebSocket connection should receive real-time updates', () async {
      // Arrange
      final updates = <Map<String, dynamic>>[];
      
      // Act
      blockchainRepository.subscribeToUpdates((update) {
        updates.add(update);
      });

      await Future.delayed(const Duration(seconds: 2));

      // Assert
      expect(updates, isNotEmpty);
    });
  });
}
