import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/theme.dart';
import '../widgets/api_key_form.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  
  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }
  
  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final apiKey = settings.apiKey;
    final isDarkMode = settings.isDarkMode;
    final hasApiKey = settings.hasApiKey;
    final currentLocale = ref.watch(localeProvider);
    
    // Get localized strings
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        // Show a message when API key is needed
        bottom: !hasApiKey ? PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            width: double.infinity,
            color: AppTheme.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Text(
              l10n.apiKeyRequired,
              style: const TextStyle(
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
                          SnackBar(
                            content: Text(l10n.apiKeySavedSuccess),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      },
                      onDelete: () {
                        ref.read(settingsProvider.notifier).deleteApiKey();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.apiKeyDeletedSuccess),
                          ),
                        );
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
                        Text(
                          l10n.appearanceSection,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: Text(l10n.darkModeLabel),
                          subtitle: Text(l10n.darkModeDescription),
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
                
                // Language Section
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.languageSection,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: currentLocale.languageCode,
                          decoration: InputDecoration(
                            labelText: l10n.languageLabel,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(l10n.englishLanguage),
                            ),
                            DropdownMenuItem(
                              value: 'ko',
                              child: Text(l10n.koreanLanguage),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(localeProvider.notifier).setLocale(Locale(value));
                            }
                          },
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
                        Text(
                          l10n.aiModelSection,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: settings.selectedModel,
                          decoration: InputDecoration(
                            labelText: l10n.aiModelLabel,
                            hintText: l10n.aiModelHint,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'gpt-4o',
                              child: Text(l10n.gpt4oModel),
                            ),
                            DropdownMenuItem(
                              value: 'gpt-4-turbo',
                              child: Text(l10n.gpt4TurboModel),
                            ),
                            DropdownMenuItem(
                              value: 'gpt-3.5-turbo',
                              child: Text(l10n.gpt35TurboModel),
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
                        Text(
                          l10n.aboutSection,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Eddie2'),
                          subtitle: Text('${l10n.versionLabel} $_appVersion'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: Text(l10n.sourceCodeLabel),
                          subtitle: Text(l10n.sourceCodeDescription),
                          onTap: () {
                            // Open GitHub repository
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.bug_report_outlined),
                          title: Text(l10n.reportIssueLabel),
                          subtitle: Text(l10n.reportIssueDescription),
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