import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sketch_day/screens/main/main_page.dart';

import '../../../../utils/authService.dart';
import '../../../../widgets/show_loading_dialog.dart';

class WriteDiaryPage extends StatefulWidget {
  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WriteDiaryPage> {
  DateTime selectedDate = DateTime.now(); // 선택된 날짜를 저장하기 위한 변수
  final TextEditingController _textEditingController = TextEditingController();
  final _authService = AuthService();

  void showDatePickerDialog() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> saveDiary() async {
    showLoadingDialog(context);
    final content = _textEditingController.text; // 일기 내용
    final url = '${dotenv.env['BASE_URL']}/diary/create';
    final accessToken = await _authService.readAccessToken() ?? '';
    final response = await _authService.post(
      url,
      accessToken,
      body: {
        'date': selectedDate.toIso8601String().split('T')[0],
        'content': content,
        'emo_id': "1",
        'wea_id': "1"
      },
    );
    Navigator.pop(context);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "일기를 작성하였습니다.");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
        (route) => route == null,
      );
    } else {
      Fluttertoast.showToast(msg: "일기 작성에 실패하였습니다.");
      print('${response.statusCode}, ${response.body}');
      print(utf8.decode(response.bodyBytes));
      throw Exception('일기 저장에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context); // 이전 페이지로 돌아가기
                  },
                  icon: const Icon(Icons.close),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    saveDiary();
                  },
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 10.0),
                Text(
                  '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDatePickerDialog();
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // 날씨 다이얼로그 표시
                  },
                  icon: const Icon(Icons.wb_sunny),
                ),
                IconButton(
                  onPressed: () {
                    // 기분 다이얼로그 표시
                  },
                  icon: const Icon(Icons.emoji_emotions),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 24.0),
              child: TextField(
                controller: _textEditingController,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: 16.0,
                  height: 1.8,
                ),
                decoration: InputDecoration(
                  hintText: '오늘 하루를 기록해보세요!',
                  contentPadding: const EdgeInsets.all(20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
