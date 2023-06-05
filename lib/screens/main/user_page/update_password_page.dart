import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../utils/authService.dart';

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _passwordError, _confirmPasswordError;

  bool _isPasswordValid = true;
  String _passwordWarning = "";
  bool _isConfirmPasswordValid = true;
  String _confirmPasswordWarning = "";
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> updatePassword(String newPwd) async {
    final url = '${dotenv.env['BASE_URL']}/auth/help/resetPW';
    final accessToken = await _authService.readAccessToken() ?? '';
    final response = await _authService.post(
      url,
      accessToken,
      body: {
        'new_password': newPwd,
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      showToast('비밀번호를 변경하였습니다.');
    } else {
      showToast('비밀번호 변경에 실패하였습니다.');
      throw Exception('비밀번호 변경 실패');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '비밀번호 변경',
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
                controller: _passwordController,
                labelText: '새 비밀번호',
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
                labelText: '새 비밀번호 확인',
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
              child: ElevatedButton(
                onPressed: (_passwordController.text.isNotEmpty &&
                        _confirmPasswordController.text.isNotEmpty &&
                        _isPasswordValid &&
                        _isConfirmPasswordValid &&
                        _passwordError == null &&
                        _confirmPasswordError == null)
                    ? () {
                        updatePassword(_passwordController.text);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width, 50),
                ),
                child: const Text('비밀번호 변경'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
