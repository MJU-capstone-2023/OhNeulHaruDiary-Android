import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

final BASE_URL = '${dotenv.env['BASE_URL']}';
const HEADER_CONTENT_TYPE = 'application/json; charset=UTF-8';

class TemporaryPwdPage extends StatefulWidget {
  const TemporaryPwdPage({super.key});

  @override
  _TemporaryPwdPageState createState() => _TemporaryPwdPageState();
}

class _TemporaryPwdPageState extends State<TemporaryPwdPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _verifyCodeController = TextEditingController();
  final ValueNotifier<bool> _canCompleteVerify = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canSendVerify = ValueNotifier<bool>(false);

  void _checkIfFieldsAreNotEmpty() {
    if (_emailController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _verifyCodeController.text.isNotEmpty) {
      _canCompleteVerify.value = true;
    } else {
      _canCompleteVerify.value = false;
    }
  }

  void _checkIfCanSendVerify() {
    if (_emailController.text.isNotEmpty && _nameController.text.isNotEmpty) {
      _canSendVerify.value = true;
    } else {
      _canSendVerify.value = false;
    }
  }

  bool _checkEmailValidity(String email) {
    String emailPattern = r'^[^@]+@[^@]+\.[^@]+$';
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(email)) {
      showToast('이메일 형태로 입력해주세요.');
      return false;
    }
    return true;
  }

  Future<void> sendVerification(String email, String name) async {
    if (!_checkEmailValidity(email)) {
      return;
    }
    try {
      final response =
          await http.post(Uri.parse('$BASE_URL/auth/help/findPW/checkEmail'),
              headers: <String, String>{
                'Content-Type': HEADER_CONTENT_TYPE,
              },
              body: jsonEncode({
                'email': email,
                'name': name,
              }));

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        print(responseJson);
        showToast('메일에 인증번호를 전송하였습니다.');
      } else {
        showToast('인증번호 전송에 실패하였습니다.\n이름과 이메일을 확인 해주세요.');
        throw Exception('인증번호 전송 실패');
      }
    } catch (e) {
      print(e.toString());
      showToast('에러가 발생하였습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  Future<void> verifyCode(String email, String verifyCode) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/auth/help/findPW/verifyEmail'),
        headers: <String, String>{
          'Content-Type': HEADER_CONTENT_TYPE,
        },
        body: jsonEncode({
          'email': email,
          'verifyCode': verifyCode,
        }),
      );

      final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
      print(responseJson);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "이메일 인증이 완료 되었습니다.");
      } else {
        Fluttertoast.showToast(msg: "인증 실패, 인증번호를 확인해주세요.");
      }
    } catch (e) {
      print(e.toString());
      showToast('에러가 발생하였습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(width: 1),
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
          '임시 비밀번호 발급',
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
            const SizedBox(height: 86),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: _buildTextFormField(
                controller: _nameController,
                labelText: '이름',
                onChanged: (value) {
                  _checkIfCanSendVerify();
                },
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
                      onChanged: (value) {
                        _checkIfCanSendVerify();
                      },
                    )
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    height: 48,
                    child: ValueListenableBuilder(
                      valueListenable: _canSendVerify,
                      builder: (BuildContext context, bool canSend, Widget? child) {
                        return ElevatedButton(
                          onPressed: canSend
                              ? () {
                            sendVerification(_emailController.text, _nameController.text);
                          }
                              : null,
                          child: const Text('인증'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: _buildTextFormField(
                controller: _verifyCodeController,
                labelText: '인증번호 입력',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _checkIfFieldsAreNotEmpty();
                },
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: ValueListenableBuilder(
                valueListenable: _canCompleteVerify,
                builder: (BuildContext context, bool canVerify, Widget? child) {
                  return ElevatedButton(
                    onPressed: canVerify
                        ? () {
                      verifyCode(_emailController.text, _verifyCodeController.text);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    ),
                    child: const Text('인증 완료'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
