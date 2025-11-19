import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_promotion_bloc.dart';
import '../bloc/user_promotion_event.dart';
import '../bloc/user_promotion_state.dart';
import '../widgets/user_promotion_card.dart';
import 'promotion_detail_page.dart';
import '../../../vendor/domain/entities/promotion_entity.dart';

class UserPromotionsPage extends StatefulWidget {
  const UserPromotionsPage({super.key});

  @override
  State<UserPromotionsPage> createState() => _UserPromotionsPageState();
}

class _UserPromotionsPageState extends State<UserPromotionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserPromotionBloc>().add(LoadUserPromotionsEvent());
    });
  }

  void _showPromotionDetail(PromotionEntity promotion) {
    if (promotion.vendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Promotion vendor information missing'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<UserPromotionBloc>().add(
          UserPromotionClickEvent(
            vendorId: promotion.vendorId!,
            promotionId: promotion.id,
          ),
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PromotionDetailPage(
          promotion: promotion,
          vendorId: promotion.vendorId!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0.5,
        title: Text(
          'Vouchers & Promotions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: BlocConsumer<UserPromotionBloc, UserPromotionState>(
        listener: (context, state) {
          if (state is UserPromotionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },

        builder: (context, state) {
          if (state is UserPromotionInitial || state is UserPromotionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserPromotionError) {
            return _errorState(theme);
          }

          if (state is UserPromotionLoaded) {
            final promotions = state.promotions;

            if (promotions.isEmpty) {
              return _emptyState(theme);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UserPromotionBloc>().add(LoadUserPromotionsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: promotions.length,
                itemBuilder: (context, index) {
                  final promotion = promotions[index];

                  return UserPromotionCard(
                    promotion: promotion,
                    onTap: () => _showPromotionDetail(promotion),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined,
                size: 70, color: theme.colorScheme.outline),
            const SizedBox(height: 20),
            Text(
              'No promotions available',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 8),
            Text(
              'Check again later to discover new vouchers and deals!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<UserPromotionBloc>().add(LoadUserPromotionsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 70, color: theme.colorScheme.error),
            const SizedBox(height: 20),
            Text(
              'Error loading promotions',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<UserPromotionBloc>().add(LoadUserPromotionsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
