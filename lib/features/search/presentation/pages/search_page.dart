import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/search/data/repositories/restaurant_loader.dart';
import 'package:makan_mate/features/search/presentation/bloc/search_bloc.dart';
import 'package:makan_mate/features/search/presentation/bloc/search_event.dart';
import 'package:makan_mate/features/search/presentation/bloc/search_state.dart';
import 'package:makan_mate/features/search/presentation/widgets/search_result_food_card.dart';
import 'package:makan_mate/features/search/presentation/widgets/search_result_restaurant_card.dart';
import 'package:makan_mate/features/search/presentation/widgets/search_suggestion_chip.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  late final RestaurantLoader loader;

  @override
  void initState() {
    super.initState();
    loader = RestaurantLoader(FirebaseFirestore.instance);
    context.read<SearchBloc>().add(SearchStarted());
  }

  Future<void> _navigateToRestaurant(String vendorId) async {
    final RestaurantEntity fullRestaurant =
        await loader.loadRestaurant(vendorId);

    Navigator.pushNamed(
      context,
      '/restaurantDetail',
      arguments: fullRestaurant,
    );
  }

  void _onSubmitted(String value) {
    context.read<SearchBloc>().add(SearchQuerySubmitted(value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search restaurants or menu items',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
            border: InputBorder.none,
          ),
          onSubmitted: _onSubmitted,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.iconTheme.color),
            onPressed: () => _onSubmitted(_controller.text),
          ),
        ],
      ),

      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final noQuery = state.currentQuery == null || state.currentQuery!.isEmpty;
          if (noQuery && state.history.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent searches',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.history.map((h) {
                      return SearchSuggestionChip(
                        label: h.query,
                        onTap: () {
                          _controller.text = h.query;
                          context.read<SearchBloc>().add(
                                SearchSuggestionTapped(h.query),
                              );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }

          final hasQuery = state.currentQuery?.isNotEmpty ?? false;
          if (hasQuery && state.restaurants.isEmpty && state.foods.isEmpty) {
            return Center(
              child: Text(
                'No results found for "${state.currentQuery}".',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.restaurants.isNotEmpty) ...[
                Text(
                  'Restaurants',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                ...state.restaurants.map(
                  (r) => SearchResultRestaurantCard(
                    restaurant: r,
                    onTap: () => _navigateToRestaurant(r.id),
                  ),
                ),

                const SizedBox(height: 24),
              ],

              if (state.foods.isNotEmpty) ...[
                Text(
                  'Menu items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                ...state.foods.map(
                  (f) => SearchResultFoodCard(
                    food: f,
                    onTap: () => _navigateToRestaurant(f.vendorId),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
