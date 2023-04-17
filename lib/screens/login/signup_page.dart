import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _authCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이름',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해 주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일 주소',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해 주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해 주세요';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인';
                  } else if (value != _passwordController.text) {
                    return '비밀번호를 한 번 더 입력해 주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _sendAuthCode();
                      },
                      child: const Text('이메일 인증'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _signUp();
                      },
                      child: const Text('회원가입'),
                    ),
                  ),
                ],
              ),
              if (_authCode != null)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Auth Code',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your auth code';
                    } else if (value != _authCode) {
                      return 'Incorrect auth code';
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendAuthCode() {
    if (_formKey.currentState!.validate()) {
      // Send auth code to email
      _authCode = '123456'; // For testing purposes
      setState(() {});
    }
  }

  void _signUp() {
    if (_formKey.currentState!.validate() && _authCode != null) {
      // Perform sign up logic here
      Navigator.pushNamed(context, '/main'); // Navigate to main page
    }
  }
}
