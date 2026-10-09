import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash/components/expense_category_badge.dart';
import 'package:dash/components/expense_category_selector.dart';
import 'package:dash/main.dart';
import 'package:dash/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateExpensePage extends ConsumerStatefulWidget {
  const CreateExpensePage({super.key});

  @override
  ConsumerState<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends ConsumerState<CreateExpensePage> {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final expenseCategoryResult = ref.watch(expenseCategoriesProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Neue Ausgabe")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                TextField(
                  autofocus: true,
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: "Beschreibung..."),
                ),
                TextField(
                  autofocus: true,
                  controller: amountController,
                  decoration: InputDecoration(hintText: "0.00 CHF"),
                ),
                RadioGroup(
                  groupValue: selectedCategoryId,
                  onChanged: (id) {
                    setState(() {
                      selectedCategoryId = id;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: expenseCategoryResult.map(
                      data: (data) => Wrap(
                        alignment: WrapAlignment.center,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: data.value
                            .map(
                              (category) => ExpenseCategorySelector(
                                category: category,
                                selected: selectedCategoryId == category.id,
                                onPressed: () {
                                  setState(() {
                                    selectedCategoryId = category.id;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      error: (error) {
                        print(error);
                        return Center(child: Text("Error: $error"));
                      },
                      loading: (_) =>
                          Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 50),
            child: FilledButton(
              onPressed: (selectedCategoryId == null)
                  ? null
                  : () {
                      firestore.collection("expenses").add({
                        "amount": double.parse(amountController.text),
                        "description": descriptionController.text,
                        "category_id": selectedCategoryId!,
                        "creation_timestamp": Timestamp.fromDate(
                          DateTime.now(),
                        ),
                        "payment_timestamp": Timestamp.fromDate(DateTime.now()),
                      });
                      context.pop();
                    },
              child: Text("Speichern"),
            ),
          ),
        ],
      ),
    );
  }
}
