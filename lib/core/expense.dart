import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String description;
  double amount;
  String categoryId;
  DateTime paymentTimestamp;
  DateTime creationTimestamp;

  Expense(this.id, this.description, this.amount, this.categoryId,
      this.paymentTimestamp, this.creationTimestamp);

  factory Expense.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final description = data["description"] as String;
    final amount = data["amount"] as double;
    final categoryId = data["category_id"] as String;
    final paymentTimestamp = (data["payment_timestamp"] as Timestamp)
        .toDate();
    final creationTimestamp = (data["creation_timestamp"] as Timestamp)
        .toDate();

    return Expense(
      id,
      description,
      amount,
      categoryId,
      paymentTimestamp,
      creationTimestamp,
    );
  }
}