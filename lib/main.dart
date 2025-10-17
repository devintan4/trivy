import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivy/screens/home/home_screen.dart';
import 'package:trivy/screens/learning/detail_screen.dart';
import 'package:trivy/screens/learning/learning_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/learning': (context) => const LearningScreen(),
        '/detail': (context) => const DetailScreen(),
      },
    );
  }
}
