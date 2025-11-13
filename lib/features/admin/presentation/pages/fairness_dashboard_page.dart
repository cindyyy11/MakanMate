import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/widgets/fairness_dashboard_widget.dart';

/// Fairness Dashboard Page
/// 
/// Displays AI recommendation fairness metrics
class FairnessDashboardPage extends StatelessWidget {
  const FairnessDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendation Fairness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminBloc>().add(const RefreshFairnessMetrics());
            },
            tooltip: 'Refresh Metrics',
          ),
        ],
      ),
      body: const FairnessDashboardWidget(),
    );
  }
}


