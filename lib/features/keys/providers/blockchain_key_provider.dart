import 'package:flutter/material.dart';
import '../services/blockchain_key_service.dart';
import '../screens/key_management_screen.dart';

class BlockchainKeyProvider extends ChangeNotifier {
  final BlockchainKeyService _keyService = BlockchainKeyService();
  
  List<BlockchainKey> _keys = [];
  bool _isLoading = false;
  String? _error;
  BlockchainKey? _generatedKey;
  
  // Getters
  List<KeyPair> get keys => _keys.map(_convertToKeyPair).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  KeyPair? get generatedKey => _generatedKey != null ? _convertToKeyPair(_generatedKey!) : null;
  
  // Convert BlockchainKey to KeyPair
  KeyPair _convertToKeyPair(BlockchainKey key) {
    return KeyPair(
      id: key.id,
      name: key.name,
      publicKey: key.publicKey,
      privateKey: key.privateKey,
      createdAt: key.createdAt,
      isActive: key.isActive,
    );
  }
  
  // Load all keys
  Future<void> loadKeys() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _keys = await _keyService.getAllKeys();
    } catch (e) {
      _error = 'Failed to load keys: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Generate a new key pair
  Future<void> generateKeyPair(String name) async {
    _isLoading = true;
    _error = null;
    _generatedKey = null;
    notifyListeners();
    
    try {
      _generatedKey = await _keyService.generateKeyPair(name);
      // Refresh the key list
      await loadKeys();
    } catch (e) {
      _error = 'Failed to generate key pair: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set key status (activate/deactivate)
  Future<void> setKeyStatus(String keyId, bool isActive) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _keyService.setKeyStatus(keyId, isActive);
      // Update the local list
      final index = _keys.indexWhere((key) => key.id == keyId);
      if (index != -1) {
        _keys[index] = _keys[index].copyWith(isActive: isActive);
      }
    } catch (e) {
      _error = 'Failed to update key status: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete a key
  Future<void> deleteKey(String keyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _keyService.deleteKey(keyId);
      // Update the local list
      _keys.removeWhere((key) => key.id == keyId);
    } catch (e) {
      _error = 'Failed to delete key: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Export a key
  Future<String?> exportKey(String keyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final exportedData = await _keyService.exportKey(keyId);
      _isLoading = false;
      notifyListeners();
      return exportedData;
    } catch (e) {
      _error = 'Failed to export key: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Import a key
  Future<void> importKey(String exportedData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _keyService.importKey(exportedData);
      // Refresh the key list
      await loadKeys();
    } catch (e) {
      _error = 'Failed to import key: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Copy to clipboard
  Future<void> copyToClipboard(String text) async {
    try {
      await _keyService.copyToClipboard(text);
    } catch (e) {
      _error = 'Failed to copy to clipboard: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Clear generated key
  void clearGeneratedKey() {
    _generatedKey = null;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}