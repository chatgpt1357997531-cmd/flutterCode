import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:adminpanelapp/screens/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // show build errors instead of white screen
  ErrorWidget.builder = (d) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Flutter error:\n${d.exceptionAsString()}', textAlign: TextAlign.center),
        ))),
      );

  runZonedGuarded(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      runApp(const MyApp());
    } catch (e, s) {
      // if Firebase init fails, render a message
      debugPrint('🔥 Firebase init error: $e\n$s');
      runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Init failed:\n$e', textAlign: TextAlign.center),
        ))),
      ));
    }
  }, (error, stack) {
    debugPrint('🔥 Uncaught zone error: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Phone Admin',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AdminHomeScreen(),
    );
  }
}
