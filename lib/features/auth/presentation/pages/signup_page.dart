import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/features/auth/presentation/widgets/signup_form.dart';
import 'package:makan_mate/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:makan_mate/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            // Animated background circles
            _buildAnimatedBackground(),
            
            // Back button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.withOpacity(AppColors.surface, 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.withOpacity(AppColors.surface, 0.5),
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          
                          // Logo with glassmorphism
                          _buildLogoSection(),
                          
                          const SizedBox(height: 32),
                          
                          // Welcome text
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: UIConstants.fontSize3Xl,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              shadows: [
                                Shadow(
                                  color: AppColors.withOpacity(AppColors.surface, 0.5),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Create your MakanMate account',
                            style: TextStyle(
                              fontSize: UIConstants.fontSizeLg,
                              color: AppColors.grey800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // SignUp Form Card
                          _buildSignUpCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Login prompt
                          _buildLoginPrompt(),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          left: -100,
          child: _buildFloatingCircle(350, AppColors.withOpacity(AppColors.surface, 0.12)),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _buildFloatingCircle(300, AppColors.withOpacity(AppColors.surface, 0.15)),
        ),
        Positioned(
          top: 300,
          right: -50,
          child: _buildFloatingCircle(200, AppColors.withOpacity(AppColors.surface, 0.1)),
        ),
      ],
    );
  }

  Widget _buildFloatingCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.withOpacity(AppColors.surface, 0.3),
        border: Border.all(
          color: AppColors.withOpacity(AppColors.surface, 0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.withOpacity(AppColors.primary, 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          'assets/images/logos/makanmate_logo.jpg',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 50,
                color: AppColors.textOnDark,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignUpCard() {
    return ClipRRect(
      borderRadius: UIConstants.borderRadiusXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: UIConstants.paddingLg,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.withOpacity(AppColors.surface, 0.4),
                AppColors.withOpacity(AppColors.surface, 0.2),
              ],
            ),
            borderRadius: UIConstants.borderRadiusXl,
            border: Border.all(
              color: AppColors.withOpacity(AppColors.surface, 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.withOpacity(AppColors.primary, 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // SignUp Form
              const SignUpForm(),
              
              const SizedBox(height: 24),
              
              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.grey600,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: UIConstants.paddingHorizontalMd,
                    child: Text(
                      'or sign up with',
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontSize: UIConstants.fontSizeSm,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.grey600,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Social Auth Buttons
              SocialAuthButton(
                icon: 'assets/images/google_logo.png',
                label: 'Sign up with Google',
                onPressed: _handleGoogleSignUp,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(AppColors.surface, 0.3),
        borderRadius: UIConstants.borderRadiusLg,
        border: Border.all(
          color: AppColors.withOpacity(AppColors.surface, 0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(
              color: AppColors.grey800,
              fontSize: UIConstants.fontSizeMd,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Login',
              style: TextStyle(
                color: AppColors.info,
                fontSize: UIConstants.fontSizeMd,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.info,
                decorationThickness: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      await _authService.signInWithGoogle();
      // Navigation handled by auth state changes
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Google Sign-Up Failed', e.toString());
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}