import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../providers/locale_provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../utils/theme.dart';
import '../widgets/api_key_form.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isUpdatingProfile = false;
  bool _isUploadingImage = false;
  String? _errorMessage;
  String? _versionInfo;
  File? _imageFile;
  Uint8List? _webImageBytes;
  String? _webImageName;
  
  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadVersionInfo();
    _loadUserProfile();
    
    // Add enhanced error logging
    if (kDebugMode) {
      debugPrint('SettingsScreen initialized');
      // Set up global error handler for Flutter errors
      FlutterError.onError = (FlutterErrorDetails details) {
        debugPrint('Flutter error in SettingsScreen: ${details.exception}');
        debugPrint('Stack trace: ${details.stack}');
      };
    }
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
  
  Future<void> _loadApiKey() async {
    final apiKey = await ref.read(settingsProvider.notifier).getApiKey();
    if (apiKey != null && mounted) {
      setState(() {
        _apiKeyController.text = apiKey;
      });
    }
  }
  
  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _versionInfo = 'v${packageInfo.version}';
        });
      }
    } catch (e) {
      debugPrint('Error loading version info: $e');
    }
  }
  
  Future<void> _loadUserProfile() async {
    try {
      final user = await ref.read(authServiceProvider).getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _displayNameController.text = user.displayName;
          _usernameController.text = user.username ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }
  
  Future<void> _saveApiKey() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(settingsProvider.notifier).setApiKey(_apiKeyController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.apiKeySaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _deleteApiKey() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(settingsProvider.notifier).deleteApiKey();
      if (mounted) {
        setState(() {
          _apiKeyController.text = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.apiKeyDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _toggleDarkMode() async {
    await ref.read(settingsProvider.notifier).toggleDarkMode();
  }
  
  Future<void> _changeLanguage(String languageCode) async {
    await ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
  }
  
  Future<void> _setModel(String model) async {
    await ref.read(settingsProvider.notifier).setSelectedModel(model);
  }
  
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authServiceProvider).signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _deleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount ?? 'Delete Account'),
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
      _errorMessage = null;
    });
    
    try {
      debugPrint('User confirmed account deletion, proceeding...');
      
      // Actually delete the account
      await ref.read(authServiceProvider).deleteAccount();
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountDeletedSuccess ?? 'Your account has been deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during account deletion process: $e');
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        
        // Show a more user-friendly error message
        String errorMessage = 'Error deleting account. Please try again later.';
        
        if (e.toString().contains('requires-recent-login') || 
            e.toString().contains('sign out and sign in again')) {
          errorMessage = 'For security reasons, please sign out and sign in again before deleting your account.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        if (kIsWeb) {
          // For web platform
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _webImageName = image.name;
          });
        } else {
          // For mobile platforms
          setState(() {
            _imageFile = File(image.path);
          });
        }
        
        // Upload the image
        await _uploadProfilePicture();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _uploadProfilePicture() async {
    if ((_imageFile == null && _webImageBytes == null) || (_isUploadingImage)) {
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      String? downloadURL;
      
      if (kIsWeb && _webImageBytes != null && _webImageName != null) {
        // Upload for web
        downloadURL = await ref.read(authServiceProvider).uploadProfilePictureWeb(
          _webImageBytes!,
          _webImageName!,
        );
      } else if (_imageFile != null) {
        // Upload for mobile
        downloadURL = await ref.read(authServiceProvider).uploadProfilePicture(_imageFile!);
      }
      
      if (downloadURL != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh auth state to update UI
        ref.refresh(authStateProvider);
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _imageFile = null;
          _webImageBytes = null;
          _webImageName = null;
        });
      }
    }
  }
  
  Future<void> _updateProfile() async {
    if (_isUpdatingProfile) {
      return;
    }

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      await ref.read(authServiceProvider).updateProfile(
        displayName: _displayNameController.text.trim(),
        username: _usernameController.text.trim().isNotEmpty 
            ? _usernameController.text.trim() 
            : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh auth state to update UI
        ref.refresh(authStateProvider);
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingProfile = false;
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
      body: authState.when(
        data: (user) => _buildSettingsContent(context, user, settings, currentLocale, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
  
  Widget _buildSettingsContent(
    BuildContext context,
    user,
    settings,
    locale,
    AppLocalizations localizations,
  ) {
    // Extract the language code from the Locale object
    final String currentLanguageCode = locale?.languageCode ?? 'en';
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (user != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.profile,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: _isUploadingImage
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                              onPressed: _isUploadingImage ? null : _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: localizations.displayName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: localizations.username,
                      border: const OutlineInputBorder(),
                      helperText: localizations.usernameHelperText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUpdatingProfile ? null : _updateProfile,
                      child: _isUpdatingProfile
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(localizations.saveChanges),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(localizations.email),
                    subtitle: Text(user.email),
                    leading: const Icon(Icons.email),
                  ),
                  ListTile(
                    title: Text(localizations.emailVerification),
                    subtitle: Text(
                      user.isEmailVerified
                          ? localizations.verified
                          : localizations.notVerified,
                    ),
                    leading: Icon(
                      user.isEmailVerified
                          ? Icons.verified_user
                          : Icons.warning,
                      color: user.isEmailVerified ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      localizations.deleteAccount,
                      style: const TextStyle(color: Colors.red),
                    ),
                    subtitle: Text(localizations.deleteAccountDescription),
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    onTap: _isDeleting ? null : () => _deleteAccount(context),
                    trailing: _isDeleting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  ),
                  ListTile(
                    title: Text(localizations.logout),
                    leading: const Icon(Icons.logout),
                    onTap: _isLoading ? null : _logout,
                    trailing: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.apiKey,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: localizations.apiKey,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _apiKeyController.clear();
                        });
                      },
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveApiKey,
                      child: Text(localizations.save),
                    ),
                    OutlinedButton(
                      onPressed: _isLoading ? null : _deleteApiKey,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(localizations.delete),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.appearance,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(localizations.darkMode),
                  value: settings.isDarkMode,
                  onChanged: (value) => _toggleDarkMode(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: currentLanguageCode,
                  decoration: InputDecoration(
                    labelText: localizations.selectLanguage,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(localizations.english),
                    ),
                    DropdownMenuItem(
                      value: 'ko',
                      child: Text(localizations.korean),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.aiModel,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: settings.selectedModel,
                  decoration: InputDecoration(
                    labelText: localizations.selectModel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'gpt-4o',
                      child: Text('GPT-4o'),
                    ),
                    DropdownMenuItem(
                      value: 'gpt-4-turbo',
                      child: Text('GPT-4 Turbo'),
                    ),
                    DropdownMenuItem(
                      value: 'gpt-3.5-turbo',
                      child: Text('GPT-3.5 Turbo'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _setModel(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.about,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(localizations.version),
                  subtitle: Text(_versionInfo ?? 'Unknown'),
                ),
                ListTile(
                  title: Text(localizations.sourceCode),
                  subtitle: const Text('https://github.com/sparabu/eddie2'),
                  onTap: () {
                    // Open source code URL
                  },
                ),
                ListTile(
                  title: Text(localizations.reportIssue),
                  subtitle: const Text('https://github.com/sparabu/eddie2/issues'),
                  onTap: () {
                    // Open issue reporting URL
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 