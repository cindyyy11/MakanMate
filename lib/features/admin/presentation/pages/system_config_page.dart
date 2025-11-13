import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';

class SystemConfigPage extends StatelessWidget {
  const SystemConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Configuration'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: UIConstants.paddingLg,
        children: [
          _buildSection(
            context,
            'Auto-Approval Settings',
            [
              _buildNumberField(context, 'Auto-approval threshold', 30),
              _buildNumberField(context, 'Deep verification threshold', 70),
            ],
          ),
          _buildSection(
            context,
            'Content Limits',
            [
              _buildNumberField(context, 'Max menu items', 100),
              _buildNumberField(context, 'Photo max size (MB)', 5),
              _buildNumberField(context, 'Review min length (chars)', 10),
            ],
          ),
          _buildSection(
            context,
            'Feature Flags',
            [
              _buildFeatureFlag(context, 'AR Food Hunt', true),
              _buildFeatureFlag(context, 'Voice Search', false),
              _buildFeatureFlag(context, 'Gamification', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingLg),
      padding: UIConstants.paddingMd,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: UIConstants.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UIConstants.spacingMd),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNumberField(BuildContext context, String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          SizedBox(
            width: 100,
            child: TextField(
              controller: TextEditingController(text: value.toString()),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFlag(BuildContext context, String name, bool value) {
    return SwitchListTile(
      title: Text(name),
      value: value,
      onChanged: (_) {},
    );
  }
}

