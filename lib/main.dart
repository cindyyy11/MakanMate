import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_bloc.dart';

// Local imports
import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;
import 'features/home/presentation/bloc/home_bloc.dart';
import 'screens/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// 💡 Force logout on startup (for debugging only)
  await FirebaseAuth.instance.signOut();
  await di.init();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => di.sl<MapBloc>()),
      ],
      child: MaterialApp(
        title: 'MakanMate',
        debugShowCheckedModeBanner: false,
        home: AuthPage(), 
      ),
    );
  }
}

