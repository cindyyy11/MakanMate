import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DietarySettingsPage extends StatefulWidget {
  const DietarySettingsPage({super.key});

  @override
  State<DietarySettingsPage> createState() => _DietarySettingsPageState();
}

class _DietarySettingsPageState extends State<DietarySettingsPage> {
  bool halalOnly = false;
  bool vegetarian = false;

  String spiceTolerance = "None";
  List<String> cuisinePreferences = [];
  List<String> dietaryRestrictions = [];
  List<String> behaviourPatterns = [];

  final List<String> cuisineOptions = [
    "Malay",
    "Chinese",
    "Indian",
    "Japanese",
    "Korean",
    "Thai",
    "Western",
    "Italian"
  ];

  final List<String> dietaryOptions = [
    "Gluten-free",
    "Lactose-free",
    "Vegan",
    "Low-carb",
    "Keto"
  ];

  final List<String> behaviourOptions = [
    "Budget eater",
    "Healthy eater",
    "Late-night eater",
    "Fast-food lover"
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    final prefs =
        (doc.data()?["dietaryPreferences"] ?? {}) as Map<String, dynamic>;

    setState(() {
      halalOnly = prefs["halalOnly"] ?? false;
      vegetarian = prefs["vegetarian"] ?? false;
      spiceTolerance = prefs["spiceTolerance"] ?? "None";

      cuisinePreferences =
          List<String>.from(prefs["cuisinePreferences"] ?? []);
      dietaryRestrictions =
          List<String>.from(prefs["dietaryRestrictions"] ?? []);
      behaviourPatterns =
          List<String>.from(prefs["behaviourPatterns"] ?? []);
    });
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "dietaryPreferences": {
        "halalOnly": halalOnly,
        "vegetarian": vegetarian,
        "spiceTolerance": spiceTolerance,
        "cuisinePreferences": cuisinePreferences,
        "dietaryRestrictions": dietaryRestrictions,
        "behaviourPatterns": behaviourPatterns,
      }
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Updated Successfully",
            style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          "Your dietary preferences have been saved.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipSelector({
    required List<String> options,
    required List<String> selectedValues,
    required Function(String) onSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Wrap(
      spacing: 10,
      children: options.map((option) {
        final selected = selectedValues.contains(option);

        return FilterChip(
          label: Text(
            option,
            style: theme.textTheme.bodyMedium,
          ),
          selected: selected,
          selectedColor: theme.colorScheme.primary.withOpacity(0.3),
          checkmarkColor: isDark ? Colors.white : Colors.black,
          backgroundColor: theme.cardColor,
          onSelected: (_) => onSelected(option),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Dietary Preferences"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // Switches are automatically theme-aware
          SwitchListTile(
            title: Text("Halal Only", style: theme.textTheme.bodyLarge),
            value: halalOnly,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) => setState(() => halalOnly = v),
          ),

          SwitchListTile(
            title: Text("Vegetarian", style: theme.textTheme.bodyLarge),
            value: vegetarian,
            activeColor: theme.colorScheme.primary,
            onChanged: (v) => setState(() => vegetarian = v),
          ),

          const SizedBox(height: 25),

          Text(
            "Spice Tolerance",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField(
            value: spiceTolerance,
            decoration: const InputDecoration(),
            dropdownColor: theme.cardColor,
            items: const [
              DropdownMenuItem(value: "None", child: Text("None")),
              DropdownMenuItem(value: "Mild", child: Text("Mild")),
              DropdownMenuItem(value: "Medium", child: Text("Medium")),
              DropdownMenuItem(value: "Hot", child: Text("Hot")),
              DropdownMenuItem(value: "Very Hot", child: Text("Very Hot")),
            ],
            onChanged: (v) => setState(() => spiceTolerance = v!),
          ),

          const SizedBox(height: 25),

          Text(
            "Cuisine Preferences",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _chipSelector(
            options: cuisineOptions,
            selectedValues: cuisinePreferences,
            onSelected: (option) {
              setState(() {
                if (cuisinePreferences.contains(option)) {
                  cuisinePreferences.remove(option);
                } else {
                  cuisinePreferences.add(option);
                }
              });
            },
          ),

          const SizedBox(height: 25),

          Text(
            "Dietary Restrictions",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _chipSelector(
            options: dietaryOptions,
            selectedValues: dietaryRestrictions,
            onSelected: (option) {
              setState(() {
                if (dietaryRestrictions.contains(option)) {
                  dietaryRestrictions.remove(option);
                } else {
                  dietaryRestrictions.add(option);
                }
              });
            },
          ),

          const SizedBox(height: 25),

          Text(
            "Eating Behaviour",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _chipSelector(
            options: behaviourOptions,
            selectedValues: behaviourPatterns,
            onSelected: (option) {
              setState(() {
                if (behaviourPatterns.contains(option)) {
                  behaviourPatterns.remove(option);
                } else {
                  behaviourPatterns.add(option);
                }
              });
            },
          ),

          const SizedBox(height: 35),

          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("Save Preferences"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
