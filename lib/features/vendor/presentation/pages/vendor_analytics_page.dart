import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/review_analytics_chart.dart';
import '../widgets/favourite_stats_card.dart';
import '../widgets/promotion_stats_card.dart';

class VendorAnalyticsPage extends StatefulWidget {
  const VendorAnalyticsPage({super.key});

  @override
  State<VendorAnalyticsPage> createState() => _VendorAnalyticsPageState();
}

class _VendorAnalyticsPageState extends State<VendorAnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        final vendorId = FirebaseAuth.instance.currentUser?.uid;
        if (vendorId != null) {
          final bloc = context.read<AnalyticsBloc>();
          bloc.add(LoadAnalytics(vendorId));
        }
      } catch (e) {
        debugPrint('Error accessing AnalyticsBloc: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        buildWhen: (previous, current) {
          return previous != current;
        },
        builder: (context, state) {
          if (state is AnalyticsInitial || state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnalyticsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        final vendorId = FirebaseAuth.instance.currentUser?.uid;
                        if (vendorId != null) {
                          context.read<AnalyticsBloc>().add(LoadAnalytics(vendorId));
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AnalyticsLoaded) {
            final vendorId = FirebaseAuth.instance.currentUser?.uid;
            if (vendorId == null) {
              return const Center(
                child: Text('User not authenticated'),
              );
            }

            final currentReviews = state.isWeeklyView
                ? state.weeklyReviews
                : state.monthlyReviews;

            if (!state.isWeeklyView && state.monthlyReviews == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AnalyticsBloc>().add(LoadMonthlyReviews(vendorId));
              });
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isWeeklyView && state.weeklyReviews == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AnalyticsBloc>().add(LoadWeeklyReviews(vendorId));
              });
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Review Graph - Let it size naturally
                    ReviewAnalyticsChart(
                      analytics: currentReviews,
                      isWeekly: state.isWeeklyView,
                      onToggleView: () {
                        if (state.isWeeklyView) {
                          context.read<AnalyticsBloc>().add(LoadMonthlyReviews(vendorId));
                        } else {
                          context.read<AnalyticsBloc>().add(LoadWeeklyReviews(vendorId));
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Row of cards - IntrinsicHeight ensures equal heights
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: FavouriteStatsCard(
                              favourites: state.favourites,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PromotionStatsCard(
                              promotions: state.promotions,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading analytics...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}