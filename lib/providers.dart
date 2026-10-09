import 'package:dash/core/expense.dart';
import 'package:dash/core/expense_category.dart';
import 'package:dash/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final expensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  return firestore
      .collection("expenses")
      .orderBy("payment_timestamp", descending: true)
      .snapshots()
      .map((docs) => docs.docs.map(Expense.fromDoc).toList());
});

final expenseCategoriesProvider =
    StreamProvider.autoDispose<List<ExpenseCategory>>((ref) {
      return firestore
          .collection("expense_categories")
          .orderBy("order")
          .snapshots()
          .map((docs) => docs.docs.map(ExpenseCategory.fromDoc).toList());
    });
