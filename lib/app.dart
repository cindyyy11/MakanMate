import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/core/theme/theme_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/promotion_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/promotion_event.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_review_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_voucher_management_bloc.dart';
import 'package:makan_mate/routes/app_router.dart';

import 'features/vendor/presentation/bloc/vendor_event.dart';

class MakanMateApp extends StatelessWidget {
  const MakanMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => ThemeBloc()),

        BlocProvider(create: (_) => di.sl<VendorBloc>()..add(LoadMenuEvent())),
        BlocProvider(
          create: (_) => di.sl<PromotionBloc>()..add(LoadPromotionsEvent()),
        ),
        BlocProvider(create: (_) => di.sl<VendorReviewBloc>()),
        BlocProvider(create: (_) => di.sl<MapBloc>()),
        BlocProvider(create: (_) => di.sl<AdminUserManagementBloc>()),
        BlocProvider(create: (_) => di.sl<AdminReviewManagementBloc>()),
        BlocProvider(create: (_) => di.sl<AdminVoucherManagementBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'MakanMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: '/',
          );
        },
      ),
    );
  }
}
