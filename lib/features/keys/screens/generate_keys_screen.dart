import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Core
import '../../../core/constants/route_names.dart';

// Features
import '../../../features/keys/providers/blockchain_key_provider.dart';

// Presentation
import '../../../presentation/widgets/layout/app_layout.dart';
import '../../../presentation/widgets/common/app_button.dart';
import '../../../presentation/widgets/common/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';

/// Generate Keys screen for creating new blockchain keys
class GenerateKeysScreen extends StatefulWidget {
  const GenerateKeysScreen({Key? key}) : super(key: key);

  @override
  State<GenerateKeysScreen> createState() => _GenerateKeysScreenState();
}

class _GenerateKeysScreenState extends State<GenerateKeysScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keyNameController = TextEditingController();
  
  bool _isGenerating = false;
  bool _isKeyGenerated = false;
  String? _errorMessage;
  
  // Generated key information
  String _publicKey = '';
  String _privateKey = '';
  
  @override
  void dispose() {
    _keyNameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Generate New Key',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding),
        child: _isKeyGenerated ? _buildKeyGeneratedView() : _buildGenerateKeyForm(),
      ),
    );
  }
  
  Widget _buildGenerateKeyForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate New Blockchain Key',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: AppDimensions.padding),
          Text(
            'Create a new cryptographic key pair for secure blockchain transactions and voting.',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.padding * 2),
          _buildKeyGenerationCard(),
          if (_errorMessage != null) ...[  
            const SizedBox(height: AppDimensions.padding),
            Container(
              padding: const EdgeInsets.all(AppDimensions.padding),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppDimensions.padding / 2),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.padding * 2),
          _buildSecurityNotice(),
        ],
      ),
    );
  }
  
  Widget _buildKeyGenerationCard() {
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
              'Key Information',
              style: AppTextStyles.heading3,
            ),
            const Divider(),
            const SizedBox(height: AppDimensions.padding),
            AppTextField(
              controller: _keyNameController,
              label: 'Key Name',
              hint: 'Enter a name for this key (e.g., "Primary Voting Key")',
              prefixIcon: const Icon(Icons.label_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for your key';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.padding * 2),
            AppButton(
              text: 'Generate Key Pair',
              icon: Icons.vpn_key,
              onPressed: _generateKeyPair,
              type: AppButtonType.primary,
              isFullWidth: true,
              isLoading: _isGenerating,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppDimensions.padding / 2),
              Text(
                'Security Notice',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.padding / 2),
          Text(
            'Your private key is the only way to access and control your blockchain assets. Keep it secure and never share it with anyone. We recommend storing it in a password manager or secure offline location.',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppDimensions.padding / 2),
          Text(
            'If you lose your private key, you will permanently lose access to any assets or votes associated with it.',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildKeyGeneratedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: AppDimensions.padding),
              Text(
                'Key Generated Successfully',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppDimensions.padding / 2),
              Text(
                'Your new blockchain key pair has been created.',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.padding * 2),
        _buildKeyDetailsCard(),
        const SizedBox(height: AppDimensions.padding * 2),
        _buildPrivateKeyWarning(),
        const SizedBox(height: AppDimensions.padding * 2),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Back to Key Management',
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pushReplacementNamed(RouteNames.keyManagement),
                type: AppButtonType.secondary,
              ),
            ),
            const SizedBox(width: AppDimensions.padding),
            Expanded(
              child: AppButton(
                text: 'Generate Another Key',
                icon: Icons.refresh,
                onPressed: _resetForm,
                type: AppButtonType.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildKeyDetailsCard() {
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
              'Key Details',
              style: AppTextStyles.heading3,
            ),
            const Divider(),
            const SizedBox(height: AppDimensions.padding),
            _buildKeyDetailRow('Name', _keyNameController.text),
            _buildKeyDetailRow('Created', _formatDate(DateTime.now())),
            const SizedBox(height: AppDimensions.padding),
            Text(
              'Public Key',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.padding / 4),
            Container(
              padding: const EdgeInsets.all(AppDimensions.padding / 2),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius / 2),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _publicKey,
                      style: AppTextStyles.code.copyWith(
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(_publicKey, 'Public key'),
                    tooltip: 'Copy public key',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.padding),
            Text(
              'Private Key',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.padding / 4),
            Container(
              padding: const EdgeInsets.all(AppDimensions.padding / 2),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius / 2),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _privateKey,
                      style: AppTextStyles.code.copyWith(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(_privateKey, 'Private key'),
                    tooltip: 'Copy private key',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKeyDetailRow(String label, String value) {
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
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrivateKeyWarning() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppColors.error,
              ),
              const SizedBox(width: AppDimensions.padding / 2),
              Text(
                'Important: Save Your Private Key',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.padding / 2),
          Text(
            'Your private key is displayed above. This is the ONLY time you will see it. Please copy and store it in a secure location immediately.',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: AppDimensions.padding / 2),
          Text(
            'Anyone with access to your private key can control your blockchain assets. Never share it with anyone.',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.padding),
          AppButton(
            text: 'I\'ve Securely Saved My Private Key',
            icon: Icons.check,
            onPressed: () => Navigator.of(context).pushReplacementNamed(RouteNames.keyManagement),
            type: AppButtonType.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
  
  Future<void> _generateKeyPair() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    
    try {
      final blockchainProvider = Provider.of<BlockchainKeyProvider>(context, listen: false);
      await blockchainProvider.generateKeyPair(_keyNameController.text);
      
      setState(() {
        _isGenerating = false;
        _isKeyGenerated = true;
        _publicKey = blockchainProvider.generatedKey?.publicKey ?? '';
        _privateKey = blockchainProvider.generatedKey?.privateKey ?? '';
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Failed to generate key pair: $e';
      });
    }
  }
  
  void _resetForm() {
    setState(() {
      _isKeyGenerated = false;
      _keyNameController.clear();
      _errorMessage = null;
      _publicKey = '';
      _privateKey = '';
    });
  }
  
  void _copyToClipboard(String text, String label) {
    final blockchainProvider = Provider.of<BlockchainKeyProvider>(context, listen: false);
    blockchainProvider.copyToClipboard(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}