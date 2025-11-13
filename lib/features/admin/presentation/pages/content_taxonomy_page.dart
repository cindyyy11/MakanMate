import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';

class ContentTaxonomyPage extends StatelessWidget {
  const ContentTaxonomyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content Taxonomy'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cuisines'),
              Tab(text: 'Dietary Tags'),
              Tab(text: 'Spice Levels'),
              Tab(text: 'Dish Aliases'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CuisinesTab(),
            _DietaryTagsTab(),
            _SpiceLevelsTab(),
            _DishAliasesTab(),
          ],
        ),
      ),
    );
  }
}

class _CuisinesTab extends StatelessWidget {
  const _CuisinesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: UIConstants.paddingLg,
      children: const [
        Chip(label: Text('Malay')),
        Chip(label: Text('Chinese')),
        Chip(label: Text('Indian')),
        Chip(label: Text('Western')),
        Chip(label: Text('Thai')),
      ],
    );
  }
}

class _DietaryTagsTab extends StatelessWidget {
  const _DietaryTagsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: UIConstants.paddingLg,
      children: const [
        ListTile(
          leading: Icon(Icons.check_circle, color: Colors.green),
          title: Text('Halal'),
        ),
        ListTile(
          leading: Icon(Icons.eco, color: Colors.green),
          title: Text('Vegan'),
        ),
      ],
    );
  }
}

class _SpiceLevelsTab extends StatelessWidget {
  const _SpiceLevelsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: UIConstants.paddingLg,
      children: const [
        ListTile(title: Text('0 - None')),
        ListTile(title: Text('1 - Mild')),
        ListTile(title: Text('2 - Medium')),
        ListTile(title: Text('3 - Spicy')),
        ListTile(title: Text('4 - Extra Spicy')),
      ],
    );
  }
}

class _DishAliasesTab extends StatelessWidget {
  const _DishAliasesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: UIConstants.paddingLg,
      children: const [
        ListTile(
          title: Text('nasi lemak'),
          subtitle: Text('nasik lemak, nasi lemak ayam'),
        ),
      ],
    );
  }
}


