import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../providers/locale_provider.dart';
import '../services/auth_service.dart';
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
  bool _isDeleting = false;
  
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
  
  Future<void> _deleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle ?? 'Delete Account'),
        content: Text(l10n.deleteAccountConfirmation ?? 'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await ref.read(authServiceProvider).deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountDeletedSuccess ?? 'Your account has been deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final apiKey = settings.apiKey;
    final isDarkMode = settings.isDarkMode;
    final hasApiKey = settings.hasApiKey;
    final currentLocale = ref.watch(localeProvider);
    final authState = ref.watch(authStateProvider);
    
    // Get localized strings
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Authentication Section
          authState.when(
            data: (user) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.authSection,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (user != null) ...[
                      // User is logged in
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(user.displayName.isNotEmpty 
                          ? user.displayName 
                          : user.email),
                        subtitle: Text(user.email),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.verified_user),
                        title: Text(l10n.emailVerificationStatus),
                        subtitle: Text(user.isEmailVerified 
                          ? l10n.emailVerified 
                          : l10n.emailNotVerified),
                        trailing: user.isEmailVerified 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : TextButton(
                              onPressed: () async {
                                try {
                                  await ref.read(authServiceProvider).sendEmailVerification();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.verifyEmailSent),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(l10n.verifyEmailButton),
                            ),
                      ),
                      const Divider(),
                      // Delete Account Button
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        title: Text(l10n.deleteAccountButton ?? 'Delete Account'),
                        subtitle: Text(l10n.deleteAccountDescription ?? 'Permanently delete your account and all associated data'),
                        onTap: _isDeleting ? null : () => _deleteAccount(context),
                        trailing: _isDeleting 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          : null,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: Text(l10n.logoutButton),
                        onTap: () async {
                          await ref.read(authServiceProvider).signOut();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.logoutSuccess),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ] else ...[
                      // User is not logged in - this should not happen as the auth wrapper
                      // should redirect to login screen, but just in case
                      const Center(
                        child: Text("You are not logged in"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text("Error: $error"),
                ),
              ),
            ),
          ),
          
          // API Key Section
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                  const SizedBox(height: 16),
                  APIKeyForm(
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
                ],
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
    );
  }
} 