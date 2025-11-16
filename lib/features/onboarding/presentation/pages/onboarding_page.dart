import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:makan_mate/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:makan_mate/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:makan_mate/features/onboarding/presentation/widgets/onboarding_page_widget.dart';

/// Onboarding page with interactive page navigation and Lottie animations
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _buttonAnimController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _buttonAnimController,
      curve: Curves.easeInOut,
    ));

    context.read<OnboardingBloc>().add(const LoadOnboardingPages());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          Navigator.of(context).pushReplacementNamed('/');
        }

        if (state is OnboardingLoaded && _pageController.hasClients) {
          // Only animate if the controller is attached to a PageView
          if (_pageController.page?.round() != state.currentPage) {
            _pageController.animateToPage(
              state.currentPage,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is OnboardingLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is OnboardingError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is OnboardingLoaded) {
          return Scaffold(
            body: Stack(
              children: [
                // PageView with onboarding pages
                PageView.builder(
                  controller: _pageController,
                  itemCount: state.pages.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    context
                        .read<OnboardingBloc>()
                        .add(UpdateCurrentPage(index));
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(
                      page: state.pages[index],
                      pageIndex: index,
                    );
                  },
                ),

                // Top skip button with animation
                Positioned(
                  top: 40,
                  right: 20,
                  child: SafeArea(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: TextButton(
                        onPressed: () {
                          context.read<OnboardingBloc>().add(const SkipOnboarding());
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          backgroundColor: AppColors.grey200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom navigation
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: SafeArea(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Page indicators
                          Row(
                            children: List.generate(
                              state.pages.length,
                              (index) => _buildPageIndicator(
                                index,
                                state.currentPage,
                              ),
                            ),
                          ),

                          // Navigation buttons
                          Row(
                            children: [
                              // Previous button (only show if not on first page)
                              if (state.currentPage > 0)
                                IconButton(
                                  onPressed: () {
                                    context
                                        .read<OnboardingBloc>()
                                        .add(const PreviousPage());
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                ),

                              const SizedBox(width: 8),

                              // Next/Get Started button with animation
                              MouseRegion(
                                onEnter: (_) => _buttonAnimController.forward(),
                                onExit: (_) => _buttonAnimController.reverse(),
                                child: ScaleTransition(
                                  scale: _buttonScaleAnimation,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (state.isLastPage) {
                                        context
                                            .read<OnboardingBloc>()
                                            .add(const CompleteOnboarding());
                                      } else {
                                        context
                                            .read<OnboardingBloc>()
                                            .add(const NextPage());
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 6,
                                      shadowColor: AppColors.primary.withAlpha(128),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          state.isLastPage ? 'Get Started' : 'Next',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          state.isLastPage
                                              ? Icons.check_circle_rounded
                                              : Icons.arrow_forward_ios_rounded,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: Text('Loading...'),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int index, int currentPage) {
    final isActive = index == currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: isActive ? 30 : 10,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.grey400,
        borderRadius: BorderRadius.circular(5),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(102),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}

