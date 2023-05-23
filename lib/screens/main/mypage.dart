import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../login/login_page.dart';

class Mypage extends StatelessWidget {
  Mypage({Key? key}) : super(key: key);

  final String logoutUrl =
      '${dotenv.env['BASE_URL']}/auth/logout'; // 로그아웃 처리를 위한 URL
  final String deleteAccountUrl =
      '${dotenv.env['BASE_URL']}/auth/signout'; // 계정 삭제 처리를 위한 URL

  Future<void> logout(BuildContext context) async {
    try {
      var response = await http.get(Uri.parse(logoutUrl));
      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } else {
        showToast('로그아웃에 실패하였습니다');
      }
    } catch (e) {
      showToast('로그아웃에 실패하였습니다');
    }
  }

  Future<bool?> showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: const Text('모든 데이터가 삭제됩니다. 정말 탈퇴하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('예'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signout(BuildContext context) async {
    bool? confirmed = await showConfirmationDialog(context);
    if (confirmed == true) {
      try {
        var response = await http.get(Uri.parse(deleteAccountUrl));
        if (response.statusCode == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        } else {
          showToast('회원탈퇴에 실패하였습니다');
        }
      } catch (e) {
        showToast('회원탈퇴에 실패하였습니다');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 13, bottom: 32),
            child: Center(
              child: Text(
                '내 정보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
            child: Text(
              '사용자 이름',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
            child: Text(
              '사용자 생일',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
            child: Text(
              '사용자 이메일',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ),
          const Divider(),
          GestureDetector(
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => PasswordChangePage()),
            //   );
            // },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '비밀번호 수정',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () => logout(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '로그아웃',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () => signout(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '회원탈퇴',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
