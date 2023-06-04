import 'dart:convert';

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
  final _verificationCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _agreedToTerms = false;
  bool _emailVerificationVisible = false;
  DateTime? _selectedDate;
  bool _emailVerificationDisabled = false;
  bool _verificationCodeDisabled = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  bool _isPasswordValid = true;
  String _passwordWarning = "";
  bool _isConfirmPasswordValid = true;
  String _confirmPasswordWarning = "";

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      setState(() {
        _verificationCodeDisabled = false;
        _emailVerificationDisabled = false;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // 비밀번호 유효성 검사
  void _validatePassword(String value) {
    final RegExp passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*\d)[a-z\d]{8,16}$');
    if (!passwordRegExp.hasMatch(value)) {
      setState(() {
        _isPasswordValid = false;
        _passwordWarning = "영어 소문자, 숫자 조합으로 8~16자 사이여야 합니다.";
      });
    } else {
      setState(() {
        _isPasswordValid = true;
        _passwordWarning = "";
      });
    }
  }

  // 비밀번호 확인
  void _validateConfirmPassword(String value) {
    if (value != _passwordController.text) {
      setState(() {
        _isConfirmPasswordValid = false;
        _confirmPasswordWarning = "비밀번호가 일치하지 않습니다.";
      });
    } else {
      setState(() {
        _isConfirmPasswordValid = true;
        _confirmPasswordWarning = "";
      });
    }
  }

  // POST: 인증번호 전송
  Future<void> _sendEmailVerification() async {
    print(_emailController.text.toString());
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(_emailController.text)) {
      Fluttertoast.showToast(msg: "이메일 형식이 아닙니다.");
      return;
    }

    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/auth/sendEmail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "인증번호를 발송하였습니다.");
      setState(() {
        _emailVerificationVisible = true;
        _emailVerificationDisabled = true;
      });
    } else {
      Fluttertoast.showToast(msg: "인증번호 발송에 실패하였습니다.");
      print(response.body);
      setState(() {
        _emailVerificationVisible = false;
      });
    }
  }

  // POST: 인증번호 검증
  Future<void> _verifyVerificationCode() async {
    print("${_emailController.text.toString()}, ${_verificationCodeController.text.toString()}");
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/auth/verifyEmail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': _emailController.text,
        'verification_code': _verificationCodeController.text,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "이메일 인증이 완료 되었습니다.");
      setState(() {
        _verificationCodeDisabled = true;
      });
    } else {
      Fluttertoast.showToast(msg: "인증 실패, 인증번호를 확인해주세요.");
    }
  }

  // POST: 회원가입
  Future<void> _handleSignup() async {
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/auth/signup'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
        'birth': _birthDateController.text,
        'name': _nameController.text,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _verificationCodeDisabled = true;
      });
      Fluttertoast.showToast(
          msg: "인증 완료 되었습니다.", backgroundColor: Colors.green);
    } else {
      Fluttertoast.showToast(msg: "인증 실패, 인증번호를 확인해주세요.");
    }
  }

  // TextFormField 생성
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    void Function(String)? onChanged,
    bool readOnly = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(width: 1),
        ),
        errorText: errorText,
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
                      onPressed: _emailVerificationDisabled
                          ? null
                          : () {
                              _sendEmailVerification();
                              FocusScope.of(context).unfocus();
                            },
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
                        onPressed: _verificationCodeDisabled
                            ? null
                            : () {
                                _verifyVerificationCode();
                              },
                        child: const Text('확인'),
                      ),
                    ),
                  ],
                ),
              ),
            if (_verificationCodeDisabled)
              const Padding(
                padding: EdgeInsets.only(left: 45),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "이메일 인증이 완료 되었습니다.",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: _buildTextFormField(
                controller: _passwordController,
                labelText: '비밀번호',
                obscureText: !_passwordVisible,
                onChanged: _validatePassword,
                keyboardType: TextInputType.visiblePassword,
                readOnly: false,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: Icon(_passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
                errorText: _isPasswordValid ? null : _passwordWarning,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: _buildTextFormField(
                controller: _confirmPasswordController,
                labelText: '비밀번호 확인',
                obscureText: !_confirmPasswordVisible,
                onChanged: _validateConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                readOnly: false,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                  icon: Icon(_confirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
                errorText:
                    _isConfirmPasswordValid ? null : _confirmPasswordWarning,
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
                    readOnly: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
              child: ElevatedButton(
                onPressed: _nameController.text.isNotEmpty &&
                        _emailController.text.isNotEmpty &&
                        _verificationCodeDisabled &&
                        _passwordController.text.isNotEmpty &&
                        _isPasswordValid &&
                        _isConfirmPasswordValid &&
                        _confirmPasswordController.text.isNotEmpty &&
                        _birthDateController.text.isNotEmpty &&
                        _agreedToTerms
                    ? _handleSignup
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
