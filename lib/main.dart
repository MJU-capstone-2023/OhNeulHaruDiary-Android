import 'package:flutter/material.dart';
import 'package:sketch_day/screens/login/login_page.dart';
import 'package:sketch_day/screens/main/main_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(); // Add this line
  runApp(MyApp());
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