import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_text_styles.dart';
import '../theme/eddie_constants.dart';
import '../widgets/eddie_logo.dart';
import '../widgets/eddie_text_field.dart';
import '../widgets/eddie_button.dart';
import '../widgets/eddie_outlined_button.dart';
import '../utils/validation_utils.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await ref.read(authServiceProvider).signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (user != null && mounted) {
        // Force refresh the auth state
        ref.refresh(authStateProvider);
        
        // Explicitly navigate to the root, which will trigger the AuthWrapper
        // to show the main screen because the user is now authenticated
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      
      // Log the error for debugging
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
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
        debugPrint('Google login successful for user: ${user.email}');
        
        // Force refresh the auth state
        ref.refresh(authStateProvider);
        
        if (mounted) {
          // Explicitly navigate to the root, which will trigger the AuthWrapper
          // to show the main screen because the user is now authenticated
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } else {
        // User canceled the sign-in flow
        debugPrint('Google sign-in canceled by user');
      }
    } catch (e) {
      debugPrint('Google login error: $e');
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

  void _navigateToSignup() {
    Navigator.of(context).pushReplacementNamed(SignupScreen.routeName);
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
                  const EddieLogo(size: 64, showText: true),
                  const SizedBox(height: 32),
                  Text(
                    localizations.loginToEddie,
                    style: EddieTextStyles.heading1(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.loginWelcomeMessage,
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieColors.getTextSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
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
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                localizations.forgotPassword,
                                style: EddieTextStyles.link(context, fontSize: 12, underline: false),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          EddieButton(
                            label: localizations.login,
                            onPressed: _login,
                            isLoading: _isLoading,
                            isExpanded: true,
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
                          // Custom implementation for Google sign-in button to handle SVG icon
                          _buildGoogleSignInButton(context, localizations),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.dontHaveAccount,
                        style: EddieTextStyles.body2(context),
                      ),
                      const SizedBox(width: 8),
                      EddieOutlinedButton(
                        label: localizations.signUp,
                        onPressed: _navigateToSignup,
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

  // Custom method to build Google sign-in button with SVG icon
  Widget _buildGoogleSignInButton(BuildContext context, AppLocalizations localizations) {
    return EddieOutlinedButton(
      label: "Sign in with Google", // Hardcoded for now until localization is updated
      onPressed: _loginWithGoogle,
      isLoading: _isGoogleLoading,
      isExpanded: true,
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

