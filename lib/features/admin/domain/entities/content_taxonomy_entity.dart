import 'package:equatable/equatable.dart';

/// Content taxonomy for cuisines, dietary tags, spice levels, dish aliases
class ContentTaxonomy extends Equatable {
  final String id;
  final List<String> cuisines; // Malay, Chinese, Indian, etc.
  final List<DietaryTag> dietaryTags; // Halal, Vegan, Gluten-Free, etc.
  final List<SpiceLevel> spiceLevels; // 0-4 scale
  final Map<String, List<String>> dishAliases; // Normalized dish names
  final DateTime lastUpdated;

  const ContentTaxonomy({
    required this.id,
    this.cuisines = const [],
    this.dietaryTags = const [],
    this.spiceLevels = const [],
    this.dishAliases = const {},
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        cuisines,
        dietaryTags,
        spiceLevels,
        dishAliases,
        lastUpdated,
      ];
}

class DietaryTag extends Equatable {
  final String id;
  final String name;
  final String code; // HALAL, VEGAN, etc.
  final String icon; // Emoji or icon code
  final bool isActive;
  final String? description;

  const DietaryTag({
    required this.id,
    required this.name,
    required this.code,
    required this.icon,
    this.isActive = true,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, code, icon, isActive, description];
}

class SpiceLevel extends Equatable {
  final int level; // 0-4
  final String name; // None, Mild, Medium, Spicy, Extra Spicy
  final String description;
  final String color; // Hex color code

  const SpiceLevel({
    required this.level,
    required this.name,
    required this.description,
    required this.color,
  });

  @override
  List<Object?> get props => [level, name, description, color];
}


