import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash/utils/color_from_hex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class ExpenseCategory {
  String id;
  String name;
  Color color;

  ExpenseCategory(this.id, this.name, this.color);

  factory ExpenseCategory.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final name = data["name"] as String;
    final hexColor = (data["hex_color"] as String).fromHexToColor();

    return ExpenseCategory(id, name, hexColor);
  }

  Color get backgroundColor {
    return HSLColor.fromColor(
      color,
    ).withSaturation(0.7).withLightness(0.75).toColor();
  }

  Color get textColor {
    return HSLColor.fromColor(
      color,
    ).withSaturation(0.9).withLightness(0.1).toColor();
  }
}

final expenseCategoryProvider = Provider.family<ExpenseCategory, String>((
  ref,
  id,
) {
  final expenseCategoryResult = ref.watch(expenseCategoriesProvider);

  return expenseCategoryResult.when(
    loading: () => ExpenseCategory(id, "Loading...", Colors.grey),
    error: (error, stackTrace) {
      print(error);
      return ExpenseCategory(id, "Error", Colors.grey);
    },
    data: (categories) {
      return categories.firstWhere(
        (cat) => cat.id == id,
        orElse: () => ExpenseCategory(id, "Unknown Category", Colors.grey),
      );
    },
  );
});
