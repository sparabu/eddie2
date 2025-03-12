import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/auth_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully with DefaultFirebaseOptions');
  } catch (e) {
    debugPrint('Failed to initialize Firebase with DefaultFirebaseOptions: $e');
    // Fallback to web-only initialization if needed
    if (e.toString().contains('web')) {
      try {
        await Firebase.initializeApp();
        debugPrint('Firebase initialized with default web configuration');
      } catch (e) {
        debugPrint('Failed to initialize Firebase with default web configuration: $e');
      }
    }
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authStateProvider);
    
    return MaterialApp(
      title: 'Eddie2',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      
      // Localization settings
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      
      // Routes
      routes: {
        '/': (context) => const AuthWrapper(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
      },
      initialRoute: '/',
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Force refresh the auth state when the wrapper is initialized
    Future.microtask(() {
      ref.refresh(authStateProvider);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        debugPrint('AuthWrapper: Current user state: ${user != null ? 'Logged in as ${user.email}' : 'Not logged in'}');
        
        if (user != null) {
          debugPrint('AuthWrapper: Navigating to MainScreen');
          return const MainScreen();
        } else {
          debugPrint('AuthWrapper: Navigating to LoginScreen');
          return const LoginScreen();
        }
      },
      loading: () {
        debugPrint('AuthWrapper: Loading authentication state...');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint('AuthWrapper: Error in authentication state: $error');
        debugPrint('Stack trace: $stackTrace');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Authentication Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Force refresh the auth state
                    ref.refresh(authStateProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
