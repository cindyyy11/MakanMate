import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';

// Local imports
import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;
import 'features/home/presentation/bloc/home_bloc.dart';
import 'screens/auth_page.dart';

// Vendor Feature imports
import 'features/vendor/presentation/bloc/vendor_bloc.dart';
import 'features/vendor/presentation/bloc/vendor_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<VendorBloc>()..add(LoadMenuEvent())),
      ],
      child: MaterialApp(
        title: 'MakanMate',
        debugShowCheckedModeBanner: false,
        home: const AuthPage(), // Use AuthPage for proper authentication flow
      ),
    );
  }
}

