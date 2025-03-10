import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import '../widgets/api_key_form.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final apiKey = settings.apiKey;
    final isDarkMode = settings.isDarkMode;
    final hasApiKey = settings.hasApiKey;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Show a message when API key is needed
        bottom: !hasApiKey ? PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            width: double.infinity,
            color: AppTheme.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: const Text(
              'Please add your OpenAI API key to get started',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ) : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // API Key Section
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: APIKeyForm(
                      initialApiKey: apiKey,
                      onSave: (newApiKey) {
                        ref.read(settingsProvider.notifier).setApiKey(newApiKey);
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('API key saved successfully. You can now use the chat!'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      },
                      onDelete: () {
                        ref.read(settingsProvider.notifier).deleteApiKey();
                      },
                    ),
                  ),
                ),
                
                // Appearance Section
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Appearance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Toggle between light and dark theme'),
                          value: isDarkMode,
                          onChanged: (value) {
                            ref.read(settingsProvider.notifier).toggleDarkMode();
                          },
                          secondary: Icon(
                            isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Model Selection Section
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Model',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: settings.selectedModel,
                          decoration: const InputDecoration(
                            labelText: 'OpenAI Model',
                            hintText: 'Select an OpenAI model',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'gpt-4o',
                              child: Text('GPT-4o (Recommended)'),
                            ),
                            DropdownMenuItem(
                              value: 'gpt-4-turbo',
                              child: Text('GPT-4 Turbo'),
                            ),
                            DropdownMenuItem(
                              value: 'gpt-3.5-turbo',
                              child: Text('GPT-3.5 Turbo (Faster)'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(settingsProvider.notifier).setSelectedModel(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // About Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Eddie2'),
                          subtitle: Text('Version 1.0.0'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text('Source Code'),
                          subtitle: const Text('View the source code on GitHub'),
                          onTap: () {
                            // Open GitHub repository
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.bug_report_outlined),
                          title: const Text('Report an Issue'),
                          subtitle: const Text('Report bugs or request features'),
                          onTap: () {
                            // Open issue reporting page
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 