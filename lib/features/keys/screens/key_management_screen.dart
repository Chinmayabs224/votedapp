import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Core
import '../../../core/constants/route_names.dart';

// Features
import '../providers/blockchain_key_provider.dart';

// Presentation
import '../../../presentation/widgets/layout/app_layout.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// Key Management screen for viewing and managing blockchain keys
class KeyManagementScreen extends StatefulWidget {
  const KeyManagementScreen({Key? key}) : super(key: key);

  @override
  State<KeyManagementScreen> createState() => _KeyManagementScreenState();
}

class _KeyManagementScreenState extends State<KeyManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load keys when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BlockchainKeyProvider>(context, listen: false).loadKeys();
    });
  }
  
  Future<void> _toggleKeyActive(BlockchainKeyProvider provider, KeyPair keyPair) async {
    await provider.setKeyStatus(keyPair.id, !keyPair.isActive);
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<BlockchainKeyProvider>(
      builder: (context, keyProvider, child) {
        return AppLayout(
          title: 'Key Management',
          child: keyProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : keyProvider.error != null
                  ? _buildErrorView(keyProvider)
                  : _buildKeyManagementView(keyProvider),
        );
      },
    );
  }
  
  Widget _buildErrorView(BlockchainKeyProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppDimensions.padding),
          Text(
            'Error',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppDimensions.padding / 2),
          Text(
            provider.error ?? 'An unknown error occurred',
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.padding),
          AppButton(
            text: 'Try Again',
            onPressed: () => provider.loadKeys(),
            type: AppButtonType.primary,
          ),
        ],
      ),
    );
  }
  
  Widget _buildKeyManagementView(BlockchainKeyProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.padding * 2),
          _buildKeysList(provider),
          const SizedBox(height: AppDimensions.padding * 2),
          _buildActions(provider),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blockchain Keys',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppDimensions.padding / 2),
        Text(
          'Manage your blockchain private and public keys for secure voting and transaction signing.',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildKeysList(BlockchainKeyProvider provider) {
    if (provider.keys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vpn_key_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.padding),
            Text(
              'No Keys Found',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppDimensions.padding / 2),
            Text(
              'You don\'t have any blockchain keys yet. Generate a new key to get started.',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Keys',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: AppDimensions.padding),
        ...List.generate(provider.keys.length, (index) {
          final key = provider.keys[index];
          return _buildKeyCard(key, provider);
        }),
      ],
    );
  }
  
  Widget _buildKeyCard(KeyPair keyPair, BlockchainKeyProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.padding),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        side: keyPair.isActive
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.vpn_key,
                        color: keyPair.isActive ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.padding / 2),
                      Expanded(
                        child: Text(
                          keyPair.name,
                          style: AppTextStyles.heading4.copyWith(
                            color: keyPair.isActive ? AppColors.primary : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (keyPair.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.padding / 2,
                      vertical: AppDimensions.padding / 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadius / 2),
                    ),
                    child: Text(
                      'Active',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.padding),
            _buildKeyInfoRow('Public Key', keyPair.publicKey),
            _buildKeyInfoRow('Created', _formatDate(keyPair.createdAt)),
            _buildKeyInfoRow('Last Used', keyPair.lastUsed != null ? _formatDate(keyPair.lastUsed!) : 'Never'),
            const SizedBox(height: AppDimensions.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
            AppButton(
              text: 'Copy Public Key',
                  icon: Icons.copy,
                  onPressed: () => provider.copyToClipboard(keyPair.publicKey),
                  type: AppButtonType.text,
                ),
                const SizedBox(width: AppDimensions.padding / 2),
                AppButton(
                  text: keyPair.isActive ? 'Deactivate' : 'Activate',
                  icon: keyPair.isActive ? Icons.close : Icons.check,
                  onPressed: () => _toggleKeyActive(provider, keyPair),
                  type: AppButtonType.text,
                  foregroundColor: keyPair.isActive ? AppColors.error : AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKeyInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.padding / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions(BlockchainKeyProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Actions',
              style: AppTextStyles.heading3,
            ),
            const Divider(),
            const SizedBox(height: AppDimensions.padding),
            AppButton(
              text: 'Generate New Key',
              icon: Icons.add,
              onPressed: () => Navigator.of(context).pushNamed(RouteNames.generateKeys),
              type: AppButtonType.primary,
              isFullWidth: true,
            ),
            const SizedBox(height: AppDimensions.padding),
            AppButton(
              text: 'Import Existing Key',
              icon: Icons.upload_file,
              onPressed: () => _showImportKeyDialog(provider),
              type: AppButtonType.secondary,
              isFullWidth: true,
            ),
            const SizedBox(height: AppDimensions.padding),
            AppButton(
              text: 'Export Active Key',
              icon: Icons.download,
              onPressed: provider.keys.any((key) => key.isActive) ? () => _exportActiveKey(provider) : null,
              type: AppButtonType.secondary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showImportKeyDialog(BlockchainKeyProvider provider) {
    final TextEditingController importController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste your exported key data below:'),
            const SizedBox(height: AppDimensions.padding),
            AppTextField(
              label: 'Key Data',
              controller: importController,
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (importController.text.isNotEmpty) {
                provider.importKey(importController.text);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
  
  void _exportActiveKey(BlockchainKeyProvider provider) async {
    final activeKey = provider.keys.firstWhere((key) => key.isActive, orElse: () => provider.keys.first);
    final exportedData = await provider.exportKey(activeKey.id);
    
    if (exportedData != null && mounted) {
      provider.copyToClipboard(exportedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Key exported and copied to clipboard')),
      );
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class KeyPair {
  final String id;
  final String name;
  final String publicKey;
  final String? privateKey;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final bool isActive;
  
  KeyPair({
    required this.id,
    required this.name,
    required this.publicKey,
    this.privateKey,
    required this.createdAt,
    this.lastUsed,
    this.isActive = false,
  });
  
  KeyPair copyWith({
    String? id,
    String? name,
    String? publicKey,
    String? privateKey,
    DateTime? createdAt,
    DateTime? lastUsed,
    bool? isActive,
  }) {
    return KeyPair(
      id: id ?? this.id,
      name: name ?? this.name,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      isActive: isActive ?? this.isActive,
    );
  }
}