import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class TemporaryPwdPage extends StatefulWidget {
  @override
  _TemporaryPwdPageState createState() => _TemporaryPwdPageState();
}

class _TemporaryPwdPageState extends State<TemporaryPwdPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verifyCodeController = TextEditingController();
  bool _canVerify = false;

  Future<void> sendVerification(String email) async {
    final response =
        await http.post(Uri.parse('${dotenv.env['BASE_URL']}/auth/sendEmail'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'email': email,
            }));

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
      print(responseJson);
      showToast('메일에 인증번호를 전송하였습니다.');
    } else {
      showToast('인증번호 전송에 실패하였습니다.');
      throw Exception('인증번호 전송 실패');
    }
  }

  Future<void> verifyCode(String email, String verifyCode) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/auth/help/findPW/verifyEmail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
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
      setState(() {
        _canVerify = true;
      });
    } else {
      Fluttertoast.showToast(msg: "인증 실패, 인증번호를 확인해주세요.");
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
              child: Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _emailController,
                      labelText: '이메일 주소',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _canVerify = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _canVerify
                          ? () {
                              sendVerification(_emailController.text);
                            }
                          : null,
                      child: const Text('인증'),
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
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: ElevatedButton(
                onPressed: (_emailController.text.isNotEmpty &&
                        _verifyCodeController.text.isNotEmpty)
                    ? () {
                        verifyCode(
                            _emailController.text, _verifyCodeController.text);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width, 50),
                ),
                child: const Text('인증 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
