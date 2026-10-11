import 'package:cloud_firestore/cloud_firestore.dart';

class ExpensePreset {
  String id;
  String description;
  double amount;
  String categoryId;

  ExpensePreset(this.id, this.description, this.amount, this.categoryId);

  factory ExpensePreset.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final description = data["description"] as String;
    final amount = data["amount"] as double;
    final categoryId = data["category_id"] as String;

    return ExpensePreset(doc.id, description, amount, categoryId);
  }
}
