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
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/eddie_text_field.dart';
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
            backgroundColor: EddieTheme.getColor(context, EddieColors.successLight, EddieColors.successDark),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
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
            backgroundColor: EddieTheme.getColor(context, EddieColors.successLight, EddieColors.successDark),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
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
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
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
              foregroundColor: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
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
        Navigator.of(context).pushReplacementNamed('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountDeletedSuccess ?? 'Your account has been deleted successfully.'),
            backgroundColor: EddieTheme.getColor(context, EddieColors.successLight, EddieColors.successDark),
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
            backgroundColor: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
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
          if (mounted) {
            setState(() {
              _webImageBytes = bytes;
              _webImageName = image.name;
            });
          }
        } else {
          // For mobile platforms
          if (mounted) {
            setState(() {
              _imageFile = File(image.path);
            });
          }
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
            backgroundColor: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
          ),
        );
      }
    }
  }
  
  Future<void> _uploadProfilePicture() async {
    if ((_imageFile == null && _webImageBytes == null) || (_isUploadingImage)) {
      return;
    }

    if (mounted) {
      setState(() {
        _isUploadingImage = true;
      });
    }

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
            backgroundColor: EddieTheme.getColor(context, EddieColors.successLight, EddieColors.successDark),
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
            backgroundColor: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
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

    if (mounted) {
      setState(() {
        _isUpdatingProfile = true;
      });
    }

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
            backgroundColor: EddieTheme.getColor(context, EddieColors.successLight, EddieColors.successDark),
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
            backgroundColor: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
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
        loading: () => Center(
          child: CircularProgressIndicator(
            color: EddieTheme.getPrimary(context),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: ${error.toString()}',
            style: EddieTextStyles.errorText(context),
          ),
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
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.profile,
                    style: EddieTextStyles.heading2(context),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: EddieTheme.getPrimary(context).withOpacity(0.1),
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: EddieTheme.getPrimary(context),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: EddieTheme.getPrimary(context),
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
                  EddieTextField(
                    label: localizations.displayName,
                    placeholder: 'Your display name',
                    controller: _displayNameController,
                  ),
                  const SizedBox(height: 16),
                  EddieTextField(
                    label: localizations.username,
                    placeholder: 'Your username',
                    controller: _usernameController,
                    helperText: localizations.usernameHelperText,
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
                  const Divider(),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      localizations.email,
                      style: EddieTextStyles.body1(context),
                    ),
                    subtitle: Text(
                      user.email,
                      style: EddieTextStyles.body2(context),
                    ),
                    leading: Icon(
                      Icons.email,
                      color: EddieTheme.getPrimary(context),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      localizations.emailVerification,
                      style: EddieTextStyles.body1(context),
                    ),
                    subtitle: Text(
                      user.isEmailVerified
                          ? localizations.verified
                          : localizations.notVerified,
                      style: EddieTextStyles.body2(context).copyWith(
                        color: user.isEmailVerified
                            ? EddieTheme.getColor(context, EddieColors.successLight, EddieColors.successDark)
                            : EddieTheme.getColor(context, EddieColors.warningLight, EddieColors.warningDark),
                      ),
                    ),
                    leading: Icon(
                      user.isEmailVerified
                          ? Icons.verified_user
                          : Icons.warning,
                      color: user.isEmailVerified
                          ? EddieTheme.getColor(context, EddieColors.successLight, EddieColors.successDark)
                          : EddieTheme.getColor(context, EddieColors.warningLight, EddieColors.warningDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  ListTile(
                    title: Text(
                      localizations.deleteAccount,
                      style: EddieTextStyles.body1(context).copyWith(
                        color: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
                      ),
                    ),
                    subtitle: Text(
                      localizations.deleteAccountDescription,
                      style: EddieTextStyles.body2(context),
                    ),
                    leading: Icon(
                      Icons.delete_forever,
                      color: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
                    ),
                    onTap: _isDeleting ? null : () => _deleteAccount(context),
                    trailing: _isDeleting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
                            ),
                          )
                        : null,
                  ),
                  ListTile(
                    title: Text(
                      localizations.logout,
                      style: EddieTextStyles.body1(context),
                    ),
                    leading: const Icon(Icons.logout),
                    onTap: _isLoading ? null : _logout,
                    trailing: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: EddieTheme.getPrimary(context),
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.apiKey,
                  style: EddieTextStyles.heading2(context),
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: EddieTextStyles.errorText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                EddieTextField(
                  label: localizations.apiKey,
                  placeholder: 'Enter your OpenAI API key',
                  controller: _apiKeyController,
                  obscureText: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _apiKeyController.clear();
                      });
                    },
                  ),
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
                        foregroundColor: EddieTheme.getColor(context, EddieColors.errorLight, EddieColors.errorDark),
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.appearance,
                  style: EddieTextStyles.heading2(context),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    localizations.darkMode,
                    style: EddieTextStyles.body1(context),
                  ),
                  value: settings.isDarkMode,
                  onChanged: (value) => _toggleDarkMode(),
                  activeColor: EddieTheme.getPrimary(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.language,
                  style: EddieTextStyles.heading2(context),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: currentLanguageCode,
                  decoration: InputDecoration(
                    labelText: localizations.selectLanguage,
                    border: const OutlineInputBorder(),
                    labelStyle: EddieTextStyles.inputLabel(context),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(
                        localizations.english,
                        style: EddieTextStyles.body1(context),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ko',
                      child: Text(
                        localizations.korean,
                        style: EddieTextStyles.body1(context),
                      ),
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.aiModel,
                  style: EddieTextStyles.heading2(context),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: settings.selectedModel,
                  decoration: InputDecoration(
                    labelText: localizations.selectModel,
                    border: const OutlineInputBorder(),
                    labelStyle: EddieTextStyles.inputLabel(context),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'gpt-4o',
                      child: Text(
                        'GPT-4o',
                        style: EddieTextStyles.body1(context),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'gpt-4-turbo',
                      child: Text(
                        'GPT-4 Turbo',
                        style: EddieTextStyles.body1(context),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'gpt-3.5-turbo',
                      child: Text(
                        'GPT-3.5 Turbo',
                        style: EddieTextStyles.body1(context),
                      ),
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.about,
                  style: EddieTextStyles.heading2(context),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    localizations.version,
                    style: EddieTextStyles.body1(context),
                  ),
                  subtitle: Text(
                    _versionInfo ?? 'Unknown',
                    style: EddieTextStyles.body2(context),
                  ),
                  leading: Icon(
                    Icons.info_outline,
                    color: EddieTheme.getPrimary(context),
                  ),
                ),
                ListTile(
                  title: Text(
                    localizations.sourceCode,
                    style: EddieTextStyles.body1(context),
                  ),
                  subtitle: Text(
                    'https://github.com/sparabu/eddie2',
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieTheme.getPrimary(context),
                    ),
                  ),
                  leading: Icon(
                    Icons.code,
                    color: EddieTheme.getPrimary(context),
                  ),
                  onTap: () {
                    // Open source code URL
                  },
                ),
                ListTile(
                  title: Text(
                    localizations.reportIssue,
                    style: EddieTextStyles.body1(context),
                  ),
                  subtitle: Text(
                    'https://github.com/sparabu/eddie2/issues',
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieTheme.getPrimary(context),
                    ),
                  ),
                  leading: Icon(
                    Icons.bug_report_outlined,
                    color: EddieTheme.getPrimary(context),
                  ),
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

