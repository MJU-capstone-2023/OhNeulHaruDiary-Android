import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sketch_day/screens/login/login_page.dart';
import 'package:sketch_day/screens/main/main_page.dart';
import 'package:sketch_day/utils/authService.dart';

Future main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final accessToken = await authService.readAccessToken();
  final refreshToken = await authService.readRefreshToken();

  if (accessToken == null && refreshToken != null) {
    final newAccessToken = await authService.refreshTokenToAccessToken(refreshToken);
    if (newAccessToken != null) {
      await authService.saveTokens(newAccessToken, refreshToken);
    }
  }

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: authService.readAccessToken() != null ? const MainPage() : LoginPage(),
      theme: ThemeData(
        fontFamily: 'Pretendard',
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
