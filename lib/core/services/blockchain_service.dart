import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../network/network_exceptions.dart';
import '../constants/app_constants.dart';

/// Service for managing blockchain operations and process lifecycle
class BlockchainService {
  static const String _blockchainExecutable = 'projectx';
  static const String _blockchainDir = 'projectx';
  static const String _apiPort = '9000';
  static const Duration _startupTimeout = Duration(seconds: 30);
  static const Duration _healthCheckInterval = Duration(seconds: 5);

  Process? _blockchainProcess;
  Timer? _healthCheckTimer;
  bool _isRunning = false;
  bool _isStarting = false;
  final Dio _dio;
  final StreamController<BlockchainStatus> _statusController = StreamController.broadcast();
  final StreamController<String> _logController = StreamController.broadcast();

  BlockchainService(this._dio);

  /// Stream of blockchain status changes
  Stream<BlockchainStatus> get statusStream => _statusController.stream;

  /// Stream of blockchain logs
  Stream<String> get logStream => _logController.stream;

  /// Current blockchain status
  bool get isRunning => _isRunning;

  /// Start the blockchain process
  Future<void> start() async {
    if (_isRunning || _isStarting) {
      throw BlockchainException('Blockchain is already running or starting');
    }

    _isStarting = true;
    _updateStatus(BlockchainStatus.starting);

    try {
      // Build the blockchain if needed
      await _buildBlockchain();

      // Start the blockchain process
      await _startBlockchainProcess();

      // Wait for the blockchain to be ready
      await _waitForBlockchainReady();

      _isRunning = true;
      _isStarting = false;
      _updateStatus(BlockchainStatus.running);

      // Start health monitoring
      _startHealthMonitoring();
    } catch (e) {
      _isStarting = false;
      _updateStatus(BlockchainStatus.error);
      await stop();
      rethrow;
    }
  }

  /// Stop the blockchain process
  Future<void> stop() async {
    _updateStatus(BlockchainStatus.stopping);

    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;

    if (_blockchainProcess != null) {
      try {
        _blockchainProcess!.kill();
        await _blockchainProcess!.exitCode.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            _blockchainProcess!.kill(ProcessSignal.sigkill);
            return -1;
          },
        );
      } catch (e) {
        // Process might already be dead
      }
      _blockchainProcess = null;
    }

    _isRunning = false;
    _isStarting = false;
    _updateStatus(BlockchainStatus.stopped);
  }

  /// Check if blockchain is healthy
  Future<bool> isHealthy() async {
    if (!_isRunning) return false;

    try {
      final response = await _dio.get(
        'http://localhost:$_apiPort/latest_block',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Submit a transaction to the blockchain
  Future<String> submitTransaction(Map<String, dynamic> transaction) async {
    if (!_isRunning) {
      throw BlockchainException('Blockchain is not running');
    }

    try {
      // In development/mock mode, skip posting to ProjectX (which expects gob-encoded TX)
      if (AppConstants.enableMockData) {
        return 'Transaction submitted (mock)';
      }

      final response = await _dio.post(
        'http://localhost:$_apiPort/tx',
        data: transaction,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return 'Transaction submitted successfully';
      } else {
        throw BlockchainException('Failed to submit transaction: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (e) {
      throw BlockchainException('Error submitting transaction: $e');
    }
  }

  /// Get block by height or hash
  Future<Map<String, dynamic>> getBlock(String hashOrHeight) async {
    if (!_isRunning) {
      throw BlockchainException('Blockchain is not running');
    }

    try {
      final response = await _dio.get('http://localhost:$_apiPort/block/$hashOrHeight');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (e) {
      throw BlockchainException('Error getting block: $e');
    }
  }

  /// Get the latest block
  Future<Map<String, dynamic>> getLatestBlock() async {
    if (!_isRunning) {
      throw BlockchainException('Blockchain is not running');
    }

    try {
      final response = await _dio.get('http://localhost:$_apiPort/latest_block');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (e) {
      throw BlockchainException('Error getting latest block: $e');
    }
  }

  /// Get transaction by hash
  Future<Map<String, dynamic>> getTransaction(String hash) async {
    if (!_isRunning) {
      throw BlockchainException('Blockchain is not running');
    }

    try {
      final response = await _dio.get('http://localhost:$_apiPort/tx/$hash');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioException(e);
    } catch (e) {
      throw BlockchainException('Error getting transaction: $e');
    }
  }

  /// Build the blockchain executable
  Future<void> _buildBlockchain() async {
    final blockchainPath = path.join(Directory.current.path, _blockchainDir);
    
    if (!Directory(blockchainPath).existsSync()) {
      throw BlockchainException('Blockchain directory not found: $blockchainPath');
    }

    _logController.add('Building blockchain...');

    try {
      final result = await Process.run(
        'go',
        ['build', '-o', _blockchainExecutable, '.'],
        workingDirectory: blockchainPath,
      );

      if (result.exitCode != 0) {
        throw BlockchainException('Failed to build blockchain: ${result.stderr}');
      }

      _logController.add('Blockchain built successfully');
    } catch (e) {
      throw BlockchainException('Error building blockchain: $e');
    }
  }

  /// Start the blockchain process
  Future<void> _startBlockchainProcess() async {
    final blockchainPath = path.join(Directory.current.path, _blockchainDir);
    var executablePath = path.join(blockchainPath, _blockchainExecutable);

    if (Platform.isWindows) {
      executablePath += '.exe';
    }

    if (!File(executablePath).existsSync()) {
      throw BlockchainException('Blockchain executable not found: $executablePath');
    }

    _logController.add('Starting blockchain process...');

    try {
      _blockchainProcess = await Process.start(
        executablePath,
        [],
        workingDirectory: blockchainPath,
      );

      // Listen to process output
      _blockchainProcess!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        _logController.add('STDOUT: $line');
      });

      _blockchainProcess!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        _logController.add('STDERR: $line');
      });

      // Monitor process exit
      _blockchainProcess!.exitCode.then((exitCode) {
        _logController.add('Blockchain process exited with code: $exitCode');
        if (_isRunning) {
          _isRunning = false;
          _updateStatus(BlockchainStatus.error);
        }
      });

      _logController.add('Blockchain process started');
    } catch (e) {
      throw BlockchainException('Error starting blockchain process: $e');
    }
  }

  /// Wait for blockchain to be ready
  Future<void> _waitForBlockchainReady() async {
    _logController.add('Waiting for blockchain to be ready...');

    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < _startupTimeout) {
      try {
        if (await isHealthy()) {
          _logController.add('Blockchain is ready');
          return;
        }
      } catch (e) {
        // Continue waiting
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    throw BlockchainException('Blockchain failed to start within timeout');
  }

  /// Start health monitoring
  void _startHealthMonitoring() {
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (timer) async {
      if (!await isHealthy()) {
        _logController.add('Blockchain health check failed');
        _updateStatus(BlockchainStatus.error);
        timer.cancel();
      }
    });
  }

  /// Update blockchain status
  void _updateStatus(BlockchainStatus status) {
    _statusController.add(status);
  }

  /// Dispose resources
  void dispose() {
    _healthCheckTimer?.cancel();
    _statusController.close();
    _logController.close();
    stop();
  }
}

/// Blockchain status enumeration
enum BlockchainStatus {
  stopped,
  starting,
  running,
  stopping,
  error,
}

/// Blockchain-specific exception
class BlockchainException implements Exception {
  final String message;
  
  const BlockchainException(this.message);
  
  @override
  String toString() => 'BlockchainException: $message';
}
