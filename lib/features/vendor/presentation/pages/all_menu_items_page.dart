import 'package:flutter/material.dart';
import 'package:makan_mate/features/vendor/domain/entities/menu_item_entity.dart';

class AllMenuItemsPage extends StatefulWidget {
  final String vendorName;
  final List<MenuItemEntity> items;

  const AllMenuItemsPage({
    super.key,
    required this.vendorName,
    required this.items,
  });

  @override
  State<AllMenuItemsPage> createState() => _AllMenuItemsPageState();
}

class _AllMenuItemsPageState extends State<AllMenuItemsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<MenuItemEntity> foodItems;
  late List<MenuItemEntity> drinkItems;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    foodItems = [];
    drinkItems = [];

    for (var item in widget.items) {
      final category = item.category.toLowerCase();

      if (category.contains("drink") ||
          category.contains("beverage") ||
          category.contains("juice") ||
          category.contains("tea") ||
          category.contains("coffee") ||
          category.contains("smoothie")) {
        drinkItems.add(item);
      } else {
        foodItems.add(item);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text("Menu • ${widget.vendorName}"),
        centerTitle: true,

        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.appBarTheme.foregroundColor,
          unselectedLabelColor:
              theme.appBarTheme.foregroundColor?.withOpacity(0.6),
          indicatorColor: theme.appBarTheme.foregroundColor,
          tabs: const [
            Tab(text: "Food"),
            Tab(text: "Drinks"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMenuGrid(context, foodItems),
          _buildMenuGrid(context, drinkItems),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, List<MenuItemEntity> list) {
    final theme = Theme.of(context);

    if (list.isEmpty) {
      return Center(
        child: Text(
          "No items available.",
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final m = list[index];
        return _menuCard(context, m);
      },
    );
  }

  Widget _menuCard(BuildContext context, MenuItemEntity m) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),

      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              m.imageUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 110, color: theme.dividerColor),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              m.name,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Text(
            "RM ${m.price.toStringAsFixed(2)}",
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
