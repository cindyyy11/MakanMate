import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_local_secure_datasource.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:makan_mate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:makan_mate/features/auth/domain/repositories/auth_repository.dart';
import 'package:makan_mate/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/home/data/datasources/restaurant_remote_datasource.dart';
import 'package:makan_mate/features/home/data/repositories/restaurant_repository_impl.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurants_usecase.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Order matters for clarity: External → Core → Features
  await _initExternal();
  await _initCore();
  _initAuth();
  _initHome();
}

// ---------------------------
// Auth
// ---------------------------
void _initAuth() {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      googleSignIn: sl(),
      forgotPassword: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      // googleSignIn is optional in the impl; we only register it on mobile,
      // so passing sl<GoogleSignIn>() is not required here.
    ),
  );
  
  // Local DS: SharedPreferences on web, SecureStorage on mobile (optional best-practice)
  if (kIsWeb) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
    );
  } else {
    // If you want to keep SharedPreferences on mobile, swap this to AuthLocalDataSourceImpl.
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalSecureDataSourceImpl(storage: sl()),
    );
  }
}


// ---------------------------
// Home / Restaurants
// ---------------------------
void _initHome() {
  // Bloc
  sl.registerFactory(() => HomeBloc(getRestaurants: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetRestaurantsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: sl()),
  );
}

// ---------------------------
// Core
// ---------------------------
Future<void> _initCore() async {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}

// ---------------------------
// External
// ---------------------------
Future<void> _initExternal() async {
  // SharedPreferences (web & mobile)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Secure storage (mobile only)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  }

  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Google Sign-In (mobile only; v7 singleton)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  }

  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
}