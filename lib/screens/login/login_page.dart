import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sketch_day/screens/login/signup_page.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sketch_day/screens/main/main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginButtonEnabled = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateLoginButtonState);
    _passwordController.addListener(_updateLoginButtonState);
  }

  void _updateLoginButtonState() {
    setState(() {
      _isLoginButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}!}/auth/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // 로그인 성공
      final responseData = json.decode(response.body);
      Navigator.pushNamed(context, '/mainpage');
    } else {
      // 로그인 실패
      Fluttertoast.showToast(msg: "로그인에 실패했습니다. 이메일 혹은 비밀번호를 다시 확인해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              },
              child: const Text('로그인 없이 진입'),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            child: Image.asset('images/logo.png'), // 로고 이미지 경로
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: '아이디 입력',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(width: 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '비밀번호 입력',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(width: 1),
                ),
                suffixIcon: IconButton( // Add this block
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('로그인 상태 유지'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: ElevatedButton(
              onPressed: _isLoginButtonEnabled ? _handleLogin: null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 모서리 둥글기
                ),
                minimumSize:
                    Size(MediaQuery.of(context).size.width, 50), // 최소 크기
              ),
              child: const Text('로그인'),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Colors.indigo, width: 1),
                minimumSize:
                    Size(MediaQuery.of(context).size.width, 50), // 최소 크기
              ),
              child: const Text('회원가입'),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text(
                  '비밀번호 찾기',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
