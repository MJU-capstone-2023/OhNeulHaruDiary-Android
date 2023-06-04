import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/authService.dart';

class CreateDiaryPage extends StatefulWidget {
  final String date;
  final String content;

  const CreateDiaryPage({Key? key, required this.date, required this.content}) : super(key: key);

  @override
  _CreateDiaryPageState createState() => _CreateDiaryPageState();
}

class _CreateDiaryPageState extends State<CreateDiaryPage> {
  Future<Map<String, dynamic>>? _diary;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '보내주신 내용을 바탕으로 일기를 작성했어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '원하시는 내용으로 수정이 가능해요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '${widget.date}년 ${widget.date}월, ${widget.date}일',
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.sunny),
              Icon(Icons.mood),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              initialValue: widget.content,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '일기 내용',
              ),
              maxLines: 5,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 저장 버튼 눌렸을 때의 동작 구현
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
