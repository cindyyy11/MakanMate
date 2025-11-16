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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Menu • ${widget.vendorName}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: "Food"),
            Tab(text: "Drinks"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMenuGrid(foodItems),
          _buildMenuGrid(drinkItems),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(List<MenuItemEntity> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "No items available.",
          style: TextStyle(fontSize: 16),
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.12),
                blurRadius: 6,
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
                      Container(height: 110, color: Colors.grey[300]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  m.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "RM ${m.price.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
