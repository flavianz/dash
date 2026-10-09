import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash/components/expense_category_badge.dart';
import 'package:dash/core/expense_category.dart';
import 'package:dash/providers.dart';
import 'package:dash/utils/date_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/expense_category_selector.dart';
import '../main.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  DateTime paymentDate = DateTime.now();
  String? selectedCategoryId;

  bool isButtonActive = true;

  @override
  Widget build(BuildContext context) {
    final expensesResult = ref.watch(expensesProvider);
    final expenseCategoryResult = ref.watch(expenseCategoriesProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: "Neu", icon: Icon(Icons.add)),
                Tab(text: "Liste", icon: Icon(Icons.list)),
                Tab(text: "Auswertung", icon: Icon(Icons.ssid_chart)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: Center()),
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              controller: descriptionController,
                              decoration: InputDecoration(
                                hintText: "Beschreibung...",
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              autofocus: true,
                              controller: amountController,
                              decoration: InputDecoration(hintText: "0.00 CHF"),
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () async {
                              final newDate = await showDatePicker(
                                context: context,
                                initialDate: paymentDate,
                                firstDate: DateTime(2007, 09, 14),
                                lastDate: DateTime(2200, 1, 1),
                              );
                              if (newDate != null) {
                                setState(() {
                                  paymentDate = newDate;
                                });
                              }
                            },
                            child: Text(() {
                              if (paymentDate.isSameDate(DateTime.now())) {
                                return "Heute";
                              } else {
                                return "${paymentDate.day}. ${paymentDate.month}. ${paymentDate.year}";
                              }
                            }()),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 50),
                        child: FilledButton.icon(
                          icon: Icon(isButtonActive ? Icons.add : Icons.check),
                          onPressed:
                              (selectedCategoryId == null || !isButtonActive)
                              ? null
                              : () async {
                                  firestore.collection("expenses").add({
                                    "amount": double.parse(
                                      amountController.text,
                                    ),
                                    "description": descriptionController.text,
                                    "category_id": selectedCategoryId!,
                                    "creation_timestamp": Timestamp.fromDate(
                                      DateTime.now(),
                                    ),
                                    "payment_timestamp": Timestamp.fromDate(
                                      paymentDate,
                                    ),
                                  });
                                  setState(() {
                                    descriptionController.clear();
                                    amountController.clear();
                                    paymentDate = DateTime.now();
                                    selectedCategoryId = null;
                                    isButtonActive = false;
                                  });
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  );
                                  setState(() {
                                    isButtonActive = true;
                                  });
                                },
                          label: Text(
                            isButtonActive ? "Hinzufügen" : "Erfasst!",
                          ),
                        ),
                      ),
                    ],
                  ),
                  expensesResult.when(
                    data: (expenses) {
                      return ListView.separated(
                        itemCount: expenses.length,
                        itemBuilder: (context, i) {
                          final expense = expenses[i];
                          return Dismissible(
                            key: Key(expense.id),
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(left: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                await firestore
                                    .collection("expenses")
                                    .doc(expense.id)
                                    .delete();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Gelöscht!"),
                                      action: SnackBarAction(
                                        label: "Zurück",
                                        onPressed: () {
                                          firestore.collection("expenses").add({
                                            "amount": expense.amount,
                                            "description": expense.description,
                                            "category_id": expense.categoryId,
                                            "creation_timestamp":
                                                expense.creationTimestamp,
                                            "payment_timestamp":
                                                expense.paymentTimestamp,
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                              return true;
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 16,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).splashColor,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                expense.paymentTimestamp.day
                                                    .toString(),
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              Text(
                                                expense
                                                    .paymentTimestamp
                                                    .monthAbbreviation,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expense.description,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          ExpenseCategoryBadge(
                                            category: ref.watch(
                                              expenseCategoryProvider(
                                                expense.categoryId,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${expense.amount.toStringAsFixed(2)} Fr.",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(thickness: 0.5);
                        },
                      );
                    },
                    error: (error, _) {
                      print(error);
                      return Center(child: Text("Error"));
                    },
                    loading: () => Center(child: CircularProgressIndicator()),
                  ),
                  Center(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
