import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:makan_mate/features/splash/presentation/bloc/splash_event.dart';
import 'package:makan_mate/features/splash/presentation/bloc/splash_state.dart';
import 'package:makan_mate/features/splash/presentation/widgets/fluid_splash_widget.dart';

/// Splash screen page with fluid animations
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    // Trigger splash start
    context.read<SplashBloc>().add(const StartSplash());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is NavigateToOnboarding) {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        } else if (state is NavigateToAuth) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      child: Scaffold(
        body: FluidSplashWidget(
          color1: AppColors.primary,
          color2: AppColors.secondary,
          color3: AppColors.aiPrimary,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with glow effect
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(128),
                          blurRadius: 50,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/images/logos/makanmate_logo.jpg',
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // App name with gradient
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient
                      .createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: const Text(
                    'MakanMate',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tagline
                const Text(
                  'Your AI-Powered Food Companion',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 60),
                
                // Loading indicator
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

