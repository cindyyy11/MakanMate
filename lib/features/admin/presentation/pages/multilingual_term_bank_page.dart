import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';

class MultilingualTermBankPage extends StatelessWidget {
  const MultilingualTermBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multilingual Term Bank'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {},
            tooltip: 'Add Translation',
          ),
        ],
      ),
      body: ListView(
        padding: UIConstants.paddingLg,
        children: [
          Card(
            child: Padding(
              padding: UIConstants.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nasi Lemak',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: UIConstants.spacingMd),
                  _buildTranslationRow('EN', 'Nasi Lemak (Coconut Rice)'),
                  _buildTranslationRow('BM', 'Nasi Lemak'),
                  _buildTranslationRow('ZH', '椰浆饭'),
                  _buildTranslationRow('TA', 'நாசி லெமக்'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationRow(String lang, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingSm),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              lang,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}


