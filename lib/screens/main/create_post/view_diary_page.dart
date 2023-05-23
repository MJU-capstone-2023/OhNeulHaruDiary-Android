import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ViewDiaryPage extends StatefulWidget {
  final int diaryId;

  ViewDiaryPage({Key? key, required this.diaryId}) : super(key: key);

  @override
  _ViewDiaryPageState createState() => _ViewDiaryPageState();
}

class _ViewDiaryPageState extends State<ViewDiaryPage> {
  Future<Map<String, dynamic>>? _diary;

  @override
  void initState() {
    super.initState();
    _diary = _fetchDiary();
  }

  Future<Map<String, dynamic>> _fetchDiary() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['BASE_URL']}/diary/login/${widget.diaryId}'),
    );
    final diary = jsonDecode(response.body);
    return diary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _diary,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
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
                        snapshot.data!['date'], // Assuming 'date' is a key in your response
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: SingleChildScrollView(
                      child: Text(
                        snapshot.data!['content'], // Assuming 'content' is a key in your response
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
