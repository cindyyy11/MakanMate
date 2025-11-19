import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/core/theme/theme_bloc.dart';

class ThemeWrapper extends StatelessWidget {
  final Widget child;

  const ThemeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Theme(
          data: state.themeMode == ThemeMode.dark
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          child: child,
        );
      },
    );
  }
}
