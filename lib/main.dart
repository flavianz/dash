import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dash/router.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: "dash-87610.firebasestorage.app"),
  ]);
  runApp(ProviderScope(child: SoonApp()));
}

final firestore = FirebaseFirestore.instance;

class SoonApp extends StatefulWidget {
  const SoonApp({super.key});

  @override
  State<SoonApp> createState() => _SoonAppState();
}

class _SoonAppState extends State<SoonApp> {
  final activeRouter = router;
  late final StreamSubscription<User?> _authSub;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        activeRouter.go("/auth");
      }
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: activeRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyMedium: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}
