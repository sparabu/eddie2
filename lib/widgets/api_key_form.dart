import 'package:flutter/material.dart';
import '../utils/theme.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API key saved successfully'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final hasApiKey = widget.initialApiKey != null && widget.initialApiKey!.isNotEmpty;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OpenAI API Key',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your API key is stored securely on your device and is never sent to our servers.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _apiKeyController,
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'Enter your OpenAI API key',
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
                return 'Please enter your API key';
              }
              if (!value.startsWith('sk-')) {
                return 'Invalid API key format. It should start with "sk-"';
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
                    children: const [
                      TextSpan(text: 'You can get your API key from '),
                      TextSpan(
                        text: 'OpenAI API Keys',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
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
                        title: const Text('Delete API Key'),
                        content: const Text(
                          'Are you sure you want to delete your API key? '
                          'You will need to enter it again to use the app.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onDelete();
                              _apiKeyController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('API key deleted'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Delete Key'),
                ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveApiKey,
                child: const Text('Save Key'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 