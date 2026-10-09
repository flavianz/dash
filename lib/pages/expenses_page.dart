import 'dart:math';

import 'package:dash/components/expense_category_badge.dart';
import 'package:dash/core/expense_category.dart';
import 'package:dash/providers.dart';
import 'package:dash/utils/color_from_hex.dart';
import 'package:dash/utils/date_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  @override
  Widget build(BuildContext context) {
    final expensesResult = ref.watch(expensesProvider);
    return Scaffold(
      body: expensesResult.when(
        data: (expenses) {
          return ListView.separated(
            itemCount: expenses.length,
            itemBuilder: (context, i) {
              final expense = expenses[i];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).splashColor,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  expense.paymentTimestamp.day.toString(),
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  expense.paymentTimestamp.monthAbbreviation,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                expenseCategoryProvider(expense.categoryId),
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
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          context.push("/expenses/create");
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
