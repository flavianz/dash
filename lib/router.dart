import 'package:dash/app.dart';
import 'package:dash/pages/create_expense_page.dart';
import 'package:dash/pages/expenses_page.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return App(child: child);
      },
      routes: [
        GoRoute(
          path: "/expenses",
          builder: (context, state) {
            return ExpensesPage();
          },
        ),
        GoRoute(
          path: "/expenses/create",
          builder: (context, state) {
            return CreateExpensePage();
          },
        ),
        GoRoute(
          path: "/",
          builder: (context, state) {
            return ExpensesPage();
          },
        ),
        GoRoute(
          path: "/auth",
          builder: (context, state) {
            return SignInScreen(
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  context.go('/');
                }),
                AuthStateChangeAction<UserCreated>((context, state) {
                  context.go('/');
                }),
              ],
            );
          },
        ),
      ],
    ),
  ],
);
