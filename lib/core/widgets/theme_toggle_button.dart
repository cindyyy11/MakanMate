import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/theme/theme_bloc.dart';

/// Theme toggle button with smooth animation - reusable across the app
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentMode = state.themeMode;
        final isDark =
            currentMode == ThemeMode.dark ||
            (currentMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: IconButton(
            key: ValueKey(isDark),
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
            onPressed: () {
              final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
              context.read<ThemeBloc>().add(ThemeChanged(newMode));
            },
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        );
      },
    );
  }
}
