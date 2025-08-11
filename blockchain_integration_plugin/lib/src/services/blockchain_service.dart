import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import '../models/blockchain_transaction.dart';
import '../models/blockchain_block.dart';
import '../models/blockchain_network_state.dart';

class BlockchainService {
  final Dio _dio = Dio();
  final String baseUrl;

  BlockchainService(this.baseUrl);

  Future<List<BlockchainTransaction>> fetchTransactions() async {
    final response = await _dio.get('$baseUrl/transactions');
    final List data = response.data;
    return data.map((json) => BlockchainTransaction.fromJson(json)).toList();
  }

  Future<BlockchainBlock> fetchLatestBlock() async {
    final response = await _dio.get('$baseUrl/latest_block');
    return BlockchainBlock.fromJson(response.data);
  }

  Future<BlockchainNetworkState> fetchNetworkState() async {
    final response = await _dio.get('$baseUrl/network_state');
    return BlockchainNetworkState.fromJson(response.data);
  }

  Future<void> submitTransaction(BlockchainTransaction transaction) async {
    final String jsonData = jsonEncode(transaction.toJson());
    await _dio.post('$baseUrl/send_transaction',
        data: jsonData,
        options: Options(headers: {'Content-Type': 'application/json'}));
  }
}
