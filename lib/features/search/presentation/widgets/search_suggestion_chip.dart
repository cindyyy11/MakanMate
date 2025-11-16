import 'package:flutter/material.dart';

class SearchSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SearchSuggestionChip({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        shape: StadiumBorder(side: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }
}
