import 'package:flutter/material.dart';
import 'package:sketch_day/screens/login/signup_page.dart';

import '../main/main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('로그인'),
              onPressed: () {
                // 로그인 버튼 클릭 시 처리할 내용
                Navigator.pushReplacement( // 현재 route를 스택에서 제거
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('회원가입'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
