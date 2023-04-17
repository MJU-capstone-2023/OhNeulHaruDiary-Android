import 'package:flutter/material.dart';
import 'package:sketch_day/screens/login/login_page.dart';

void main() {
  runApp(MyApp()); // 앱 진입점
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: LoginPage(),
    );
  }
}