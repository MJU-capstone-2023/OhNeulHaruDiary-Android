import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _emailVerificationVisible = false;
  bool _agreedToTerms = false;

  Future<void> _sendEmailVerification() async {
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(_emailController.text)) {
      Fluttertoast.showToast(
        msg: "이메일 형식이 아닙니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // Implement your email verification logic here
    await http.post(
      Uri.parse(dotenv.env['API_URL']!),
      body: {
        'email': _emailController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration _inputDecoration({required String labelText}) {
      return InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(width: 1),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '회원가입',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 72),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(labelText: '이름'),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(labelText: '이메일 주소'),
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _emailVerificationVisible = true;
                        });
                        _sendEmailVerification();
                      },
                      child: const Text('인증'),
                    ),
                  ),
                ],
              ),
            ),
            if (_emailVerificationVisible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _verificationCodeController,
                        decoration: _inputDecoration(labelText: '인증번호'),
                      ),
                    ),
                    const SizedBox(width: 18),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _emailVerificationVisible = true;
                        });
                        _sendEmailVerification();
                      },
                      child: const Text('인증'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration(labelText: '비밀번호'),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _inputDecoration(labelText: '비밀번호 확인'),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: TextFormField(
                controller: _birthDateController,
                keyboardType: TextInputType.datetime,
                decoration: _inputDecoration(labelText: '생년월일'),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: _agreedToTerms,
                onChanged: (bool? value) {
                  setState(() {
                    _agreedToTerms = value!;
                  });
                },
                title: const Text('서비스 약관 동의'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: ElevatedButton(
                onPressed: _nameController.text.isNotEmpty &&
                    _emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _confirmPasswordController.text.isNotEmpty &&
                    _birthDateController.text.isNotEmpty &&
                    _agreedToTerms
                    ? () { }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize:
                  Size(MediaQuery.of(context).size.width, 50), // 최소 크기
                ),
                child: const Text('회원가입'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
