import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class App extends ConsumerStatefulWidget {
  final Widget child;

  const App({super.key, required this.child});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      ("/expenses", NavigationDestination(label: "Augaben", icon: Icon(Icons.attach_money))),
      ("/notifications", NavigationDestination(label: "Nachrichten", icon: Icon(Icons.notifications_none))),
    ];

    return Scaffold(
      body: Padding(padding: EdgeInsets.all(12), child: widget.child),
      bottomNavigationBar:
          NavigationBar(
                destinations:
                    destinations.map((dest) => dest.$2).toList(),
                selectedIndex: pageIndex,
                onDestinationSelected: (i) {
                  setState(() {
                    pageIndex = i;
                    context.go(destinations[i].$1);
                  });
                },
                elevation: 5,
              ),
    );
  }
}

Widget handleErrorWidget(error, stackTrace) {
  print(error);
  print(stackTrace);
  return Center(child: Text("Ups, hier hat etwas nicht geklappt"));
}
