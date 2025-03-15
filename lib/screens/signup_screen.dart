import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eddie2/services/auth_service.dart';
import 'package:eddie2/screens/login_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/eddie_theme.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_constants.dart';
import '../widgets/eddie_logo.dart';
import '../widgets/eddie_text_field.dart';
import '../widgets/eddie_button.dart';
import '../widgets/eddie_outlined_button.dart';
import '../utils/validation_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends ConsumerStatefulWidget {
  static const routeName = '/signup';

  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create user with email and password
      final user = await ref.read(authServiceProvider).createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
      
      if (user != null) {
        // Update display name if provided
        if (_nameController.text.isNotEmpty) {
          try {
            await ref.read(authServiceProvider).updateProfile(
                  displayName: _nameController.text.trim(),
                );
          } catch (e) {
            // Non-critical error, just log it
            debugPrint('Failed to update display name: $e');
          }
        }
        
        // Send email verification
        try {
          await ref.read(authServiceProvider).sendEmailVerification();
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.accountCreatedSuccess),
                backgroundColor: EddieColors.getColor(context, Colors.green.shade200, Colors.green.shade800),
              ),
            );
          }
        } catch (e) {
          // Non-critical error, just log it
          debugPrint('Failed to send verification email: $e');
          
          // Still show success message for account creation
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.accountCreatedSuccess),
                backgroundColor: EddieColors.getColor(context, Colors.green.shade200, Colors.green.shade800),
              ),
            );
          }
        }
      }
      
      // Navigation will be handled by the auth state listener in main.dart
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
      
      // Log the error for debugging
      debugPrint('Signup error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      // Clear any existing auth state first
      await ref.read(authServiceProvider).signOut();
      
      // Attempt to sign in with Google
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      
      if (user != null) {
        debugPrint('Google signup successful for user: ${user.email}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.accountCreatedSuccess),
              backgroundColor: EddieColors.getColor(context, Colors.green.shade200, Colors.green.shade800),
            ),
          );
        }
        
        // Force refresh the auth state
        ref.refresh(authStateProvider);
      } else {
        // User canceled the sign-in flow
        debugPrint('Google sign-in canceled by user');
      }
      
      // Navigation will be handled by the auth state listener in main.dart
    } catch (e) {
      debugPrint('Google signup error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: EddieColors.getBackground(context),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const EddieLogo(size: 64, withText: true),
                  const SizedBox(height: 24), // Reduced spacing
                  Text(
                    localizations.createAccount,
                    style: EddieTextStyles.heading1(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.createAccountSubtitle,
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieColors.getTextSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24), // Reduced spacing
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: EddieColors.getError(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: EddieColors.getError(context),
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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: EddieColors.getSurface(context),
                      borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
                      border: Border.all(
                        color: EddieColors.getOutline(context),
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EddieTextField(
                            label: localizations.name,
                            labelSuffix: localizations.nameOptional,
                            placeholder: localizations.namePlaceholder,
                            controller: _nameController,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: EddieColors.getTextSecondary(context),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          EddieTextField(
                            label: localizations.email,
                            placeholder: localizations.emailPlaceholder,
                            controller: _emailController,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: EddieColors.getTextSecondary(context),
                              size: 20,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailController.text.isEmpty ? null : 
                              !ValidationUtils.isValidEmail(_emailController.text) ? 
                              localizations.invalidEmail : null,
                          ),
                          const SizedBox(height: 16),
                          EddieTextField(
                            label: localizations.password,
                            placeholder: '••••••••',
                            controller: _passwordController,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: EddieColors.getTextSecondary(context),
                              size: 20,
                            ),
                            obscureText: true,
                            errorText: _passwordController.text.isEmpty ? null : 
                              !ValidationUtils.isValidPassword(_passwordController.text) ? 
                              localizations.passwordTooShort : null,
                          ),
                          const SizedBox(height: 16),
                          EddieTextField(
                            label: localizations.confirmPassword,
                            placeholder: '••••••••',
                            controller: _confirmPasswordController,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: EddieColors.getTextSecondary(context),
                              size: 20,
                            ),
                            obscureText: true,
                            errorText: _confirmPasswordController.text.isEmpty ? null : 
                              !ValidationUtils.doPasswordsMatch(_passwordController.text, _confirmPasswordController.text) ? 
                              localizations.passwordsDoNotMatch : null,
                          ),
                          const SizedBox(height: 24),
                          EddieButton(
                            text: localizations.signUp,
                            onPressed: _signup,
                            isLoading: _isLoading,
                            fullWidth: true,
                            size: EddieButtonSize.medium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: EddieColors.getOutline(context),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  localizations.or,
                                  style: EddieTextStyles.caption(context),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: EddieColors.getOutline(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Custom implementation for Google sign-up button to handle SVG icon
                          _buildGoogleSignUpButton(context, localizations),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Reduced spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.alreadyHaveAccount,
                        style: EddieTextStyles.body2(context),
                      ),
                      const SizedBox(width: 8),
                      EddieOutlinedButton(
                        text: localizations.login,
                        onPressed: _navigateToLogin,
                        isLoading: false,
                        size: EddieButtonSize.small,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom method to build Google sign-up button with SVG icon
  Widget _buildGoogleSignUpButton(BuildContext context, AppLocalizations localizations) {
    return EddieOutlinedButton(
      text: "Sign up with Google", // Hardcoded for now until localization is updated
      onPressed: _signUpWithGoogle,
      isLoading: _isGoogleLoading,
      fullWidth: true,
      size: EddieButtonSize.medium,
      leadingIconWidget: SvgPicture.asset(
        'assets/images/google_logo.svg',
        height: 20,
        width: 20,
        placeholderBuilder: (BuildContext context) => Icon(
          Icons.account_circle,
          size: 20,
          color: EddieColors.getTextPrimary(context),
        ),
      ),
    );
  }
}

