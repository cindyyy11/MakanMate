import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:makan_mate/app.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/core/utils/logger.dart';
import 'package:makan_mate/firebase_options.dart';
import 'package:makan_mate/services/metrics_service.dart';
import 'package:makan_mate/core/services/push_notification_service.dart';

/// Background message handler - MUST be top-level function
/// This runs in a separate isolate when app is terminated or in background
///
/// **What it uses:**
/// - Firebase Cloud Messaging (FCM) service
/// - Runs in background isolate (separate from main app)
/// - Handles notifications when app is closed or backgrounded
///
/// **When it's called:**
/// - App is terminated and notification arrives
/// - App is in background and notification arrives
/// - System shows notification automatically
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Log the notification
  log.i('Background message received: ${message.messageId}');
  log.i('Notification title: ${message.notification?.title}');
  log.i('Notification body: ${message.notification?.body}');
  log.i('Notification data: ${message.data}');

  // You can process data here, update local database, etc.
  // Note: Can't show UI or navigate here - runs in background isolate
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler BEFORE runApp()
  // This allows notifications to be handled when app is terminated
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize push notification service listeners
  // This sets up handlers for foreground messages and notification taps
  PushNotificationService.initializeListeners();



  await dotenv.load(fileName: ".env");

  // 4) Hive (local storage)
  await Hive.initFlutter();

  // 5) Dependency injection
  await di.init();

  // 6) Initialize metrics service for automatic data tracking
  await MetricsService().initialize();

  // 7) Lock orientation (as you had it)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 8) Run the app
  runApp(const MakanMateApp());
}

/* 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(AppStarted())),
        BlocProvider(create: (_) => di.sl<VendorBloc>()..add(LoadMenuEvent())),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => di.sl<MapBloc>()),
      ],
      child: MaterialApp(
        title: 'MakanMate',
        debugShowCheckedModeBanner: false,
        routes: {
          '/vendorOnboarding': (_) => const VendorOnboardingPage(),
          '/pendingApproval': (_) => PendingApprovalPage(
            onBackToLogin: () {
              // This route is used only for navigation overview; the actual
              // AuthBloc listener will handle resetting state.
            },
          ),
        },
        home: const AuthPage(), // Use AuthPage for proper authentication flow
      ),
    );
  }
} */
