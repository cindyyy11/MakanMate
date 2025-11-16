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
    // Load full real RestaurantEntity from Firestore
    final RestaurantEntity fullRestaurant =
        await loader.loadRestaurant(vendorId);

    Navigator.pushNamed(
      context,
      '/restaurantDetail',
      arguments: fullRestaurant, // Router expects RestaurantEntity
    );
  }

  void _onSubmitted(String value) {
    context.read<SearchBloc>().add(SearchQuerySubmitted(value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search restaurants or menu items',
            border: InputBorder.none,
          ),
          onSubmitted: _onSubmitted,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _onSubmitted(_controller.text),
          ),
        ],
      ),

      // ======================== BODY ========================
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // show search history
          if ((state.currentQuery == null || state.currentQuery!.isEmpty) &&
              state.history.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent searches',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: state.history
                        .map(
                          (h) => SearchSuggestionChip(
                            label: h.query,
                            onTap: () {
                              _controller.text = h.query;
                              context
                                  .read<SearchBloc>()
                                  .add(SearchSuggestionTapped(h.query));
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            );
          }

          // no results
          if (state.restaurants.isEmpty &&
              state.foods.isEmpty &&
              (state.currentQuery?.isNotEmpty ?? false)) {
            return Center(
              child: Text(
                'No results found for "${state.currentQuery}".',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          // ======================== RESULTS =========================
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // -- Restaurants --
              if (state.restaurants.isNotEmpty) ...[
                Text(
                  'Restaurants',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
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

              // -- Menu Items --
              if (state.foods.isNotEmpty) ...[
                Text(
                  'Menu items',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
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
