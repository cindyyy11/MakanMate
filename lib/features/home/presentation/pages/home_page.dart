import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_state.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_event.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_state.dart';
import 'package:makan_mate/features/home/presentation/widgets/restaurant_card.dart';
import 'package:makan_mate/features/home/presentation/widgets/ai_recommendations_section.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<HomeBloc>()..add(const LoadRestaurants()),
        ),
        BlocProvider(create: (_) => di.sl<RecommendationBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                // Access the user’s displayName or email
                final user = authState.user;
                return Text('Welcome, ${user.displayName ?? user.email}');
              }
              return const Text('MakanMate');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Navigate to search page
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'test_model') {
                  Navigator.pushNamed(context, '/model-testing');
                } else if (value == 'logout') {
                  context.read<AuthBloc>().add(SignOutRequested());
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'test_model',
                  child: Row(
                    children: [
                      Icon(Icons.science, size: 20),
                      SizedBox(width: 8),
                      Text('Test AI Model'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(const LoadRestaurants());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(RefreshRestaurants());
                },
                child: ListView(
                  children: [
                    // AI Recommendations Section
                    const AIRecommendationsSection(),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'All Restaurants',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),

                    // Restaurants List
                    ...state.restaurants.map(
                      (restaurant) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: RestaurantCard(restaurant: restaurant),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
