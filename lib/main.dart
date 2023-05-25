import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sketch_day/screens/login/login_page.dart';
import 'package:sketch_day/screens/main/main_page.dart';

Future main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  final storage = new FlutterSecureStorage();
  String? jwtToken = await storage.read(key: 'jwt_token');
  runApp(MyApp(jwtToken: jwtToken));
}

class MyApp extends StatelessWidget {
  final String? jwtToken;

  MyApp({Key? key, this.jwtToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: jwtToken != null ? const MainPage() : LoginPage(),
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFF093879),
          secondary: Colors.indigo,
          background: Colors.white,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black,
          onError: Colors.black,
          error: Colors.red,
          brightness: Brightness.light,
        ),
      ),
    );
  }
}
