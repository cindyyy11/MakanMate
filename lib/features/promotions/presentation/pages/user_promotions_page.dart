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
        const SnackBar(
          content: Text('Error: Promotion vendor information missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Track click
    context.read<UserPromotionBloc>().add(
          UserPromotionClickEvent(
            vendorId: promotion.vendorId!,
            promotionId: promotion.id,
          ),
        );

    // Show detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromotionDetailPage(
          promotion: promotion,
          vendorId: promotion.vendorId!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vouchers & Promotions',
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
      body: BlocConsumer<UserPromotionBloc, UserPromotionState>(
        listener: (context, state) {
          if (state is UserPromotionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserPromotionInitial || state is UserPromotionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserPromotionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading promotions',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserPromotionBloc>().add(LoadUserPromotionsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is UserPromotionLoaded) {
            final promotions = state.promotions;

            if (promotions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_offer_outlined,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No promotions available',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new vouchers and promotions',
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserPromotionBloc>().add(LoadUserPromotionsEvent());
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UserPromotionBloc>().add(LoadUserPromotionsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
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
}

