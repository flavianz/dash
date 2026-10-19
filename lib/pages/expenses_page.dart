import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash/components/expense_category_badge.dart';
import 'package:dash/components/expense_preset_button.dart';
import 'package:dash/core/expense_category.dart';
import 'package:dash/providers.dart';
import 'package:dash/utils/date_extension.dart';
import 'package:dash/utils/sum.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/expense_category_selector.dart';
import '../core/expense.dart';
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

  int activeMonth = DateTime.now().month;
  int activeYear = DateTime.now().year;

  int activeBarYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final expensesResult = ref.watch(expensesProvider);
    final expenseCategoryResult = ref.watch(expenseCategoriesProvider);
    final expensePresetsResult = ref.watch(expensePresetsProvider);
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
                      Expanded(
                        child: expensePresetsResult.when(
                          data: (expensePresets) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: GridView.count(
                                childAspectRatio: 2,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                crossAxisCount: 3,
                                children: expensePresets.map((expensePreset) {
                                  return ExpensePresetButton(
                                    expensePreset: expensePreset,
                                    onPressed: () {
                                      firestore.collection("expenses").add({
                                        "description":
                                            expensePreset.description,
                                        "amount": expensePreset.amount,
                                        "category_id": expensePreset.categoryId,
                                        "creation_timestamp":
                                            Timestamp.fromDate(DateTime.now()),
                                        "payment_timestamp": Timestamp.fromDate(
                                          DateTime.now(),
                                        ),
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                          error: (error, stackTrace) {
                            print(error);
                            print(stackTrace);
                            return Center(child: Text("$error"));
                          },
                          loading: () =>
                              Center(child: CircularProgressIndicator()),
                        ),
                      ),
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
                              keyboardType: TextInputType.number,
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
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
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
                                    "amount": num.parse(amountController.text),
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
                            secondaryBackground: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            background: Container(
                              color: Colors.greenAccent,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 20),
                              child: Icon(Icons.edit, color: Colors.white),
                            ),
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
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                // edit
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ExpenseEditDialog(expense: expense);
                                  },
                                );
                                return false;
                              }
                              return true;
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.description,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
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
                                  ),
                                  Text(
                                    "${expense.amount.toStringAsFixed(2)} Fr.",
                                    style: TextStyle(
                                      fontSize: 22,
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
                  ListView(
                    children: [
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            spacing: 10,
                            children: [
                              Row(
                                children: [
                                  IconButton.filled(
                                    onPressed: () {
                                      setState(() {
                                        if (activeMonth == 1) {
                                          activeMonth = 12;
                                          activeYear -= 1;
                                        } else {
                                          activeMonth -= 1;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.arrow_left),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        () {
                                          final month = switch (activeMonth) {
                                            1 => "Januar",
                                            2 => "Februar",
                                            3 => "März",
                                            4 => "April",
                                            5 => "Mai",
                                            6 => "Juni",
                                            7 => "Juli",
                                            8 => "August",
                                            9 => "September",
                                            10 => "Oktober",
                                            11 => "November",
                                            12 => "Dezember",
                                            _ => "Fehler",
                                          };
                                          return month +
                                              (activeYear != DateTime.now().year
                                                  ? " $activeYear"
                                                  : "");
                                        }(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton.filled(
                                    onPressed: () {
                                      setState(() {
                                        if (activeMonth == 12) {
                                          activeMonth = 1;
                                          activeYear += 1;
                                        } else {
                                          activeMonth += 1;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.arrow_right),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 300,
                                child: () {
                                  final expenses =
                                      expensesResult.value?.where(
                                        (expense) =>
                                            expense.paymentTimestamp.year ==
                                                activeYear &&
                                            expense.paymentTimestamp.month ==
                                                activeMonth,
                                      ) ??
                                      [];
                                  final total = expenses
                                      .map((expense) => expense.amount)
                                      .sum();
                                  return Stack(
                                    children: [
                                      PieChart(
                                        duration: Duration(milliseconds: 350),
                                        PieChartData(
                                          sections: expenseCategoryResult.when(
                                            data: (expenseCategories) {
                                              return expenseCategories.map((
                                                category,
                                              ) {
                                                final expenseCategoryTotal =
                                                    expenses
                                                        .where(
                                                          (expense) =>
                                                              expense
                                                                  .categoryId ==
                                                              category.id,
                                                        )
                                                        .map(
                                                          (expense) =>
                                                              expense.amount,
                                                        )
                                                        .sum();
                                                return PieChartSectionData(
                                                  radius: 75,
                                                  title:
                                                      expenseCategoryTotal /
                                                              total >
                                                          0.05
                                                      ? "${expenseCategoryTotal.toStringAsFixed(2)} Fr."
                                                      : "",
                                                  color:
                                                      category.backgroundColor,
                                                  value:
                                                      (expenseCategoryTotal
                                                                  .toDouble() *
                                                              100)
                                                          .roundToDouble() /
                                                      100,
                                                );
                                              }).toList();
                                            },
                                            error: (error, stackTrace) {
                                              print(error);
                                              print(stackTrace);
                                              return [];
                                            },
                                            loading: () => [],
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "${total.toStringAsFixed(2)} Fr.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            spacing: 30,
                            children: [
                              Row(
                                children: [
                                  IconButton.filled(
                                    onPressed: () {
                                      setState(() {
                                        activeBarYear--;
                                      });
                                    },
                                    icon: Icon(Icons.arrow_left),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        activeBarYear.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton.filled(
                                    onPressed: () {
                                      setState(() {
                                        activeBarYear++;
                                      });
                                    },
                                    icon: Icon(Icons.arrow_right),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 300,
                                child: () {
                                  final expenses =
                                      expensesResult.value?.where(
                                        (expense) =>
                                            expense.paymentTimestamp.year ==
                                            activeBarYear,
                                      ) ??
                                      [];
                                  final Map<int, Iterable<Expense>>
                                  groupedExpenses = {};
                                  for (int i = 1; i <= 12; i++) {
                                    groupedExpenses[i] = expenses.where(
                                      (expense) =>
                                          expense.paymentTimestamp.month == i,
                                    );
                                  }

                                  final categories =
                                      expenseCategoryResult.value ?? [];

                                  return BarChart(
                                    BarChartData(
                                      borderData: FlBorderData(show: false),
                                      gridData: FlGridData(
                                        checkToShowVerticalLine: (_) => false,
                                      ),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (i, _) {
                                              return Text(
                                                switch (i) {
                                                  1 => "JAN",
                                                  2 => "FEB",
                                                  3 => "MÄR",
                                                  4 => "APR",
                                                  5 => "MAI",
                                                  6 => "JUN",
                                                  7 => "JUL",
                                                  8 => "AUG",
                                                  9 => "SEP",
                                                  10 => "OKT",
                                                  11 => "NOV",
                                                  12 => "DEZ",
                                                  _ => "ERR",
                                                },
                                                style: TextStyle(fontSize: 11),
                                              );
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            interval: 100,
                                            getTitlesWidget: (i, meta) {
                                              return SideTitleWidget(
                                                meta: meta,
                                                space: 0,
                                                child: i.toInt() % 100 == 0
                                                    ? Text("${i.toInt()} ")
                                                    : Container(),
                                              );
                                            },
                                          ),
                                        ),
                                        rightTitles: AxisTitles(),
                                        topTitles: AxisTitles(),
                                      ),
                                      barGroups: groupedExpenses.entries.map((
                                        expenseGroup,
                                      ) {
                                        double height = 0;
                                        return BarChartGroupData(
                                          groupVertically: true,
                                          x: expenseGroup.key,
                                          barRods: categories.map((category) {
                                            final categoryGroupExpenses =
                                                expenseGroup.value.where(
                                                  (expense) =>
                                                      expense.categoryId ==
                                                      category.id,
                                                );
                                            final sum = categoryGroupExpenses
                                                .map(
                                                  (expenses) => expenses.amount,
                                                )
                                                .sum();
                                            final startHeight = height;
                                            height += sum;
                                            return BarChartRodData(
                                              borderRadius: BorderRadius.zero,
                                              width: 15,
                                              fromY: startHeight,
                                              toY: height,
                                              color: category.backgroundColor,
                                            );
                                          }).toList(),
                                        );
                                      }).toList(),
                                    ),
                                    duration: Duration(milliseconds: 350),
                                  );
                                }(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseEditDialog extends ConsumerStatefulWidget {
  final Expense expense;
  const ExpenseEditDialog({super.key, required this.expense});

  @override
  ConsumerState<ExpenseEditDialog> createState() => _ExpenseEditDialogState();
}

class _ExpenseEditDialogState extends ConsumerState<ExpenseEditDialog> {
  final editDescriptionController = TextEditingController();
  final editAmountController = TextEditingController();

  DateTime editPaymentDate = DateTime.now();
  String? editSelectedCategoryId;

  bool hasBeenInit = false;

  @override
  Widget build(BuildContext context) {
    final expenseCategoryResult = ref.watch(expenseCategoriesProvider);

    if (!hasBeenInit) {
      editDescriptionController.text = widget.expense.description;
      editAmountController.text = widget.expense.amount.toString();
      editPaymentDate = widget.expense.paymentTimestamp;
      editSelectedCategoryId = widget.expense.categoryId;
      hasBeenInit = true;
    }

    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Ausgabe bearbeiten",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(controller: editDescriptionController),
            TextField(controller: editAmountController),
            SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () async {
                final newDate = await showDatePicker(
                  context: context,
                  initialDate: editPaymentDate,
                  firstDate: DateTime(2007, 09, 14),
                  lastDate: DateTime(2200, 1, 1),
                );
                if (newDate != null) {
                  setState(() {
                    editPaymentDate = newDate;
                  });
                }
              },
              iconAlignment: IconAlignment.start,
              label: Text(editPaymentDate.dateString()),
              icon: Icon(Icons.calendar_month),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: expenseCategoryResult.map(
                data: (data) => Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: data.value
                      .map(
                        (category) => ExpenseCategorySelector(
                          category: category,
                          selected: editSelectedCategoryId == category.id,
                          onPressed: () {
                            setState(() {
                              editSelectedCategoryId = category.id;
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
                loading: (_) => Center(child: CircularProgressIndicator()),
              ),
            ),
            Expanded(child: Center()),
            Row(
              spacing: 6,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: Text("Abbrechen"),
                ),
                FilledButton(
                  onPressed: () {
                    firestore
                        .collection("expenses")
                        .doc(widget.expense.id)
                        .update({
                          "amount": double.parse(editAmountController.text),
                          "description": editDescriptionController.text,
                          "category_id": editSelectedCategoryId,
                          "creation_timestamp": Timestamp.fromDate(
                            DateTime.now(),
                          ),
                          "payment_timestamp": editPaymentDate,
                        });
                    context.pop();
                  },
                  child: Text("Speichern"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
