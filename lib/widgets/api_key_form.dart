import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_theme.dart';
import '../widgets/eddie_text_field.dart';

class APIKeyForm extends StatefulWidget {
  final String? initialApiKey;
  final Function(String) onSave;
  final VoidCallback onDelete;
  
  const APIKeyForm({
    Key? key,
    this.initialApiKey,
    required this.onSave,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  State<APIKeyForm> createState() => _APIKeyFormState();
}

class _APIKeyFormState extends State<APIKeyForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _obscureText = true;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialApiKey != null) {
      _apiKeyController.text = widget.initialApiKey!;
    }
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
  
  void _saveApiKey() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_apiKeyController.text);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final hasApiKey = widget.initialApiKey != null && widget.initialApiKey!.isNotEmpty;
    final l10n = AppLocalizations.of(context)!;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.apiKeySection,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.apiKeySecureStorage,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _apiKeyController,
            decoration: InputDecoration(
              labelText: l10n.apiKeyLabel,
              hintText: l10n.apiKeyHint,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            obscureText: _obscureText,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.apiKeyValidationEmpty;
              }
              if (!value.startsWith('sk-')) {
                return l10n.apiKeyValidationFormat;
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                    children: [
                      TextSpan(text: '${l10n.apiKeyHelperText} '),
                      TextSpan(
                        text: l10n.apiKeyHelperLink,
                        style: TextStyle(
                          color: EddieColors.getPrimary(context),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasApiKey)
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.deleteApiKeyConfirmTitle),
                        content: Text(l10n.deleteApiKeyConfirmMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.cancelButton),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onDelete();
                              _apiKeyController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(l10n.deleteButton),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(l10n.deleteApiKeyButton),
                ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveApiKey,
                child: Text(l10n.saveApiKeyButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 