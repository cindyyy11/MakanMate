import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';

class FeatureFlagPage extends StatelessWidget {
  const FeatureFlagPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Flag Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {},
            tooltip: 'Add Feature Flag',
          ),
        ],
      ),
      body: ListView(
        padding: UIConstants.paddingLg,
        children: [
          _buildFeatureFlagCard(
            context,
            'AR Food Hunt',
            true,
            100,
          ),
          _buildFeatureFlagCard(
            context,
            'Voice Search',
            false,
            20,
          ),
          _buildFeatureFlagCard(
            context,
            'New UI',
            false,
            0,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFlagCard(
    BuildContext context,
    String name,
    bool isEnabled,
    int rolloutPercentage,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingMd),
      child: Padding(
        padding: UIConstants.paddingMd,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    isEnabled
                        ? 'ON ($rolloutPercentage% users)'
                        : 'OFF',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}


