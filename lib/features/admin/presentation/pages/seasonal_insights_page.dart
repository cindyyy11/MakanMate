import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/widgets/seasonal_insights_widget.dart';

/// Seasonal Insights Page
///
/// Admin page for viewing seasonal trend analysis
class SeasonalInsightsPage extends StatelessWidget {
  const SeasonalInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seasonal Trend Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminBloc>().add(const RefreshSeasonalTrends());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: const SeasonalInsightsWidget(),
    );
  }
}


