import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:makan_mate/app.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/core/utils/logger.dart';
import 'package:makan_mate/firebase_options.dart';

// import 'package:makan_mate/screens/home_screen.dart';
// import 'screens/auth_page.dart';
// import 'screens/login_page.dart';
// import 'package:google_sign_in/google_sign_in.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   await GoogleSignIn.instance.initialize(
//     clientId: '400315761727-mkpcelmpnfm7bdtp94k4n42boa8b5ud7.apps.googleusercontent.com',
//     serverClientId: '400315761727-2gk4u6jv5b5f3j3v4t1h1f4b3q7k5j4m.apps.googleusercontent.com',
//   );

//     runApp(const MyApp());
//   }
 

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: AuthPage(),
//     );
//   }
// }


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2) Crashlytics (enable in release, disable in debug)
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // Forward Flutter framework errors to Crashlytics (and our logger)
  FlutterError.onError = (FlutterErrorDetails details) {
    log.e('Flutter framework error', details.exception, details.stack);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Forward uncaught async errors (Zones) to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    log.e('Uncaught async error', error, stack);
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // // 3) (Optional but recommended) Firebase App Check
  // // Requires you to set up platform providers:
  // // - Web: reCAPTCHA v3 or Enterprise -> replace 'YOUR_RECAPTCHA_V3_SITE_KEY'
  // // - Android: Play Integrity (default), iOS: DeviceCheck/App Attest
  // try {
  //   await FirebaseAppCheck.instance.activate(
  //     webProvider: kIsWeb
  //         ? ReCaptchaV3Provider('YOUR_RECAPTCHA_V3_SITE_KEY') // TODO: set site key
  //         : null,
  //     androidProvider: AndroidProvider.playIntegrity,
  //     appleProvider: AppleProvider.appAttest, // or .deviceCheck
  //   );
  // } catch (e, st) {
  //   // Don't block the app if App Check init fails; just log.
  //   log.w('App Check activation failed: $e');
  //   log.e('App Check stack', e, st);
  // }

  // 4) Hive (local storage)
  await Hive.initFlutter();

  // 5) Dependency injection
  await di.init();

  // 6) Lock orientation (as you had it)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 7) Run the app in a guarded zone (extra safety net)
  runZonedGuarded(
    () => runApp(const MakanMateApp()),
    (error, stack) {
      log.e('runZonedGuarded error', error, stack);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}