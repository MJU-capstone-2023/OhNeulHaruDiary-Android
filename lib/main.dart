import 'package:flutter/material.dart';
import 'package:sketch_day/screens/login/login_page.dart';
import 'package:sketch_day/screens/main/main_page.dart';

void main() {
  runApp(MyApp()); // 앱 진입점
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/main': (context) => const MainPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo),
      ),
    );
  }
}