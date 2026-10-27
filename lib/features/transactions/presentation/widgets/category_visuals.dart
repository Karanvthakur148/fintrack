import 'package:flutter/material.dart';

/// Icon + color for a category id. Kept in the presentation layer so the
/// domain stays free of Flutter imports.
class CategoryVisual {
  const CategoryVisual(this.icon, this.color);

  final IconData icon;
  final Color color;
}

abstract final class CategoryVisuals {
  static const CategoryVisual _fallback =
      CategoryVisual(Icons.category_rounded, Color(0xFF78909C));

  static const Map<String, CategoryVisual> _map = {
    'food': CategoryVisual(Icons.restaurant_rounded, Color(0xFFEF6C00)),
    'transport':
        CategoryVisual(Icons.directions_car_rounded, Color(0xFF1E88E5)),
    'shopping': CategoryVisual(Icons.shopping_bag_rounded, Color(0xFF8E24AA)),
    'bills': CategoryVisual(Icons.receipt_long_rounded, Color(0xFF546E7A)),
    'health': CategoryVisual(Icons.local_hospital_rounded, Color(0xFFE53935)),
    'entertainment': CategoryVisual(Icons.movie_rounded, Color(0xFFD81B60)),
    'education': CategoryVisual(Icons.school_rounded, Color(0xFF3949AB)),
    'other_expense':
        CategoryVisual(Icons.more_horiz_rounded, Color(0xFF78909C)),
    'salary': CategoryVisual(Icons.payments_rounded, Color(0xFF0F9D6B)),
    'freelance': CategoryVisual(Icons.laptop_mac_rounded, Color(0xFF00897B)),
    'investment': CategoryVisual(Icons.trending_up_rounded, Color(0xFF43A047)),
    'other_income': CategoryVisual(Icons.savings_rounded, Color(0xFF7CB342)),
  };

  static CategoryVisual of(String categoryId) => _map[categoryId] ?? _fallback;
}
