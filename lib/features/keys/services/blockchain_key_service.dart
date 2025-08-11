import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class BlockchainKeyService {
  // Singleton instance
  static final BlockchainKeyService _instance = BlockchainKeyService._internal();
  factory BlockchainKeyService() => _instance;
  BlockchainKeyService._internal();

  // Mock storage for keys
  final List<BlockchainKey> _keys = [];
  
  // Method to generate a new key pair
  Future<BlockchainKey> generateKeyPair(String name) async {
    // In a real implementation, this would call the native code or backend API
    // to generate an actual blockchain key pair using proper cryptographic methods
    
    // For demonstration purposes, we'll create a simulated key pair
    final random = Random.secure();
    final privateKeyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final privateKey = base64Encode(privateKeyBytes);
    
    // Derive a public key (in a real implementation this would use proper EC math)
    final publicKeyBytes = List<int>.generate(33, (i) => 
      i == 0 ? 0x02 : privateKeyBytes[i - 1] ^ random.nextInt(256));
    final publicKey = base64Encode(publicKeyBytes);
    
    // Create a new key object
    final key = BlockchainKey(
      id: 'key_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      publicKey: publicKey,
      privateKey: privateKey,
      createdAt: DateTime.now(),
      isActive: true,
    );
    
    // Add to our mock storage
    _keys.add(key);
    
    return key;
  }
  
  // Get all keys
  Future<List<BlockchainKey>> getAllKeys() async {
    // In a real implementation, this would fetch keys from secure storage
    if (_keys.isEmpty) {
      // Add some sample keys for demonstration
      _keys.addAll([
        BlockchainKey(
          id: 'key_1',
          name: 'Election Admin Key',
          publicKey: 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE8HNbF/h/QhUF6/n1Jj/ndGR9Jqw+qH+ui8hzs2nA+9UVEq8t+mvUaKYkMnBaJUt8LYJgFOxdLqN1wy+ZWvUDlw==',
          privateKey: '[SECURED]',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          isActive: true,
        ),
        BlockchainKey(
          id: 'key_2',
          name: 'Backup Key',
          publicKey: 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEv4PN7FVzDqrP8R1hZ9UxVTKO+Ut8KSNq0zcQV3M6A6Qh5Rg/5Jg4VVBVbCiE0GWnhDRLAqgVUJL8xG1EzozZcA==',
          privateKey: '[SECURED]',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          isActive: false,
        ),
      ]);
    }
    
    return Future.value(_keys);
  }
  
  // Activate/deactivate a key
  Future<void> setKeyStatus(String keyId, bool isActive) async {
    final keyIndex = _keys.indexWhere((key) => key.id == keyId);
    if (keyIndex != -1) {
      _keys[keyIndex] = _keys[keyIndex].copyWith(isActive: isActive);
    }
    return Future.value();
  }
  
  // Delete a key
  Future<void> deleteKey(String keyId) async {
    _keys.removeWhere((key) => key.id == keyId);
    return Future.value();
  }
  
  // Export a key (in a real implementation, this would involve secure export procedures)
  Future<String> exportKey(String keyId) async {
    final key = _keys.firstWhere((key) => key.id == keyId);
    final exportData = {
      'id': key.id,
      'name': key.name,
      'publicKey': key.publicKey,
      'privateKey': key.privateKey,
      'createdAt': key.createdAt.toIso8601String(),
      'isActive': key.isActive,
    };
    return jsonEncode(exportData);
  }
  
  // Import a key (in a real implementation, this would involve secure import procedures)
  Future<BlockchainKey> importKey(String exportedData) async {
    final data = jsonDecode(exportedData) as Map<String, dynamic>;
    final key = BlockchainKey(
      id: data['id'],
      name: data['name'],
      publicKey: data['publicKey'],
      privateKey: data['privateKey'],
      createdAt: DateTime.parse(data['createdAt']),
      isActive: data['isActive'],
    );
    
    // Check if key already exists
    final existingIndex = _keys.indexWhere((k) => k.id == key.id);
    if (existingIndex != -1) {
      _keys[existingIndex] = key;
    } else {
      _keys.add(key);
    }
    
    return key;
  }
  
  // Copy key to clipboard
  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}

class BlockchainKey {
  final String id;
  final String name;
  final String publicKey;
  final String privateKey;
  final DateTime createdAt;
  final bool isActive;
  
  const BlockchainKey({
    required this.id,
    required this.name,
    required this.publicKey,
    required this.privateKey,
    required this.createdAt,
    required this.isActive,
  });
  
  BlockchainKey copyWith({
    String? id,
    String? name,
    String? publicKey,
    String? privateKey,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return BlockchainKey(
      id: id ?? this.id,
      name: name ?? this.name,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}