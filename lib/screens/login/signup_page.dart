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
  DateTime? _selectedDate;

  Future<void> _sendEmailVerification() async {
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(_emailController.text)) {
      Fluttertoast.showToast(msg: "이메일 형식이 아닙니다.");
      return;
    }

    // Implement your email verification logic here
    await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}!}/auth/signup'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'birth': _birthDateController.text,
      },
    );
  }

  // 비밀번호 확인 함수
  void _checkPasswordsMatch() {
    if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "비밀번호가 일치하지 않습니다");
    }
  }

  // TextFormField 생성을 위한 함수
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(width: 1),
        ),
      ),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: _buildTextFormField(
                controller: _nameController,
                labelText: '이름',
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _emailController,
                      labelText: '이메일 주소',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _emailController.text.isNotEmpty ? () {
                              setState(() {
                                _emailVerificationVisible = true;
                              });
                              _sendEmailVerification();
                              FocusScope.of(context).unfocus();
                            } : null,
                      child: const Text('인증'),
                    ),
                  ),
                ],
              ),
            ),
            if (_emailVerificationVisible)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 42, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _verificationCodeController,
                        labelText: '인증번호',
                      ),
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _verificationCodeController.text.isNotEmpty ? () {
                                setState(() {
                                  _emailVerificationVisible = true;
                                });
                                _sendEmailVerification();
                                FocusScope.of(context).unfocus();
                              } : null,
                        child: const Text('확인'),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: _buildTextFormField(
                controller: _passwordController,
                labelText: '비밀번호',
                obscureText: true,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: _buildTextFormField(
                controller: _confirmPasswordController,
                labelText: '비밀번호 확인',
                obscureText: true,
                onChanged: (value) =>
                    _checkPasswordsMatch(),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: InkWell(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _birthDateController.text =
                          '${picked.year}-${picked.month}-${picked.day}';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextFormField(
                    controller: _birthDateController,
                    labelText: '생년월일',
                    keyboardType: TextInputType.datetime,
                  ),
                ),
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
                    ? () {}
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
