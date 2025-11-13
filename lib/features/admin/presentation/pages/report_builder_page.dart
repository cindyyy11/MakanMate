import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';

class ReportBuilderPage extends StatelessWidget {
  const ReportBuilderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {},
            tooltip: 'Create Report',
          ),
        ],
      ),
      body: ListView(
        padding: UIConstants.paddingLg,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.assessment_rounded),
              title: const Text('Vendor Performance Report'),
              subtitle: const Text('Last 30 days • PDF'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}


