import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/auth_service.dart';
import 'utils/theme.dart';

// Global error handler for uncaught errors
void _handleError(Object error, StackTrace stack) {
  debugPrint('Global error handler caught: $error');
  debugPrint('Stack trace: $stack');
  
  // Log to Crashlytics if available
  if (Firebase.apps.isNotEmpty && !kIsWeb) {
    try {
      FirebaseCrashlytics.instance.recordError(error, stack);
    } catch (e) {
      debugPrint('Error recording to Crashlytics: $e');
    }
  }
}

// Initialize logging
void _setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
      debugPrint('Stack trace: ${record.stackTrace}');
    }
  });
}

void main() {
  // Ensure Flutter is initialized first
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up logging
  _setupLogging();
  final log = Logger('main');
  log.info('Starting Eddie2 application');
  
  // Set up global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    log.severe('Flutter error: ${details.exception}');
    log.severe('Stack trace: ${details.stack}');
    
    // Log to Crashlytics if available and not on web
    if (Firebase.apps.isNotEmpty && !kIsWeb) {
      try {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } catch (e) {
        log.severe('Error recording to Crashlytics: $e');
      }
    }
  };
  
  // Handle uncaught async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    _handleError(error, stack);
    return true;
  };
  
  // Use a single zone for the entire app
  runZonedGuarded(() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      log.info('Firebase initialized successfully with DefaultFirebaseOptions');
      
      // Initialize Firebase Analytics
      final analytics = FirebaseAnalytics.instance;
      log.info('Firebase Analytics initialized');
      
      // Initialize Firebase Crashlytics (only for non-web platforms)
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        log.info('Firebase Crashlytics initialized');
      }
      
      // Configure Firestore settings
      // Note: For web, persistence is configured in index.html
      if (!kIsWeb) {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        log.info('Firestore configured with persistence enabled');
      } else {
        log.info('Firestore persistence for web configured in index.html');
      }
      
      // Initialize Sentry
      if (kReleaseMode) {
        await SentryFlutter.init(
          (options) {
            options.dsn = ''; // Add your Sentry DSN here if you have one
            options.tracesSampleRate = 1.0;
            options.enableAutoSessionTracking = true;
          },
        );
        log.info('Sentry initialized');
      }
      
      // Run the app
      runApp(
        const ProviderScope(
          child: MyApp(),
        ),
      );
    } catch (e, stack) {
      log.severe('Error during app initialization: $e');
      log.severe('Stack trace: $stack');
      _handleError(e, stack);
      
      // Show a minimal error app if initialization fails
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Initialization Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ));
    }
  }, (error, stack) {
    log.severe('Uncaught error in zone: $error');
    log.severe('Stack trace: $stack');
    _handleError(error, stack);
  });
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
