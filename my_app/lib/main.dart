import 'package:flutter/material.dart';
import 'features/letter_tracing/presentation/pages/letter_tracing_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letter Tracing',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LetterTracingScreen(),
    );
  }
}