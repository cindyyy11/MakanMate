import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';

class GeographicHeatmapPage extends StatelessWidget {
  const GeographicHeatmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geographic Heatmaps'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, size: 64),
            SizedBox(height: UIConstants.spacingMd),
            Text('Malaysia Map with Heatmap'),
            Text('User density and vendor distribution'),
          ],
        ),
      ),
    );
  }
}


