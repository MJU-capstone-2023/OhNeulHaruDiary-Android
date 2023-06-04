import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sketch_day/screens/main/create_post/update_diary_page.dart';

import '../../../utils/authService.dart';
import '../main_page.dart';

class ViewDiaryPage extends StatefulWidget {
  final String diaryId;
  const ViewDiaryPage({Key? key, required this.diaryId}) : super(key: key);

  @override
  _ViewDiaryPageState createState() => _ViewDiaryPageState();
}

class _ViewDiaryPageState extends State<ViewDiaryPage> {
  Future<Map<String, dynamic>>? _diary;
  final _authService = AuthService();
  String _imageURL = '';

  Future<void> _fetchImageURL() async {
    final url = '${dotenv.env['BASE_URL']}/diary/createImg?id=${widget.diaryId}';
    final accessToken = await _authService.readAccessToken() ?? '';
    final response = await _authService.patch(url, accessToken);

    if (response.statusCode == 200) {
      setState(() {
        _imageURL = response.body; // TODO: 받아온 url로 변경 필요
      });
    } else {
      Fluttertoast.showToast(msg: "그림 생성에 실패했습니다.");
      throw Exception('그림 생성에 실패했습니다.');
    }
  }

  @override
  void initState() {
    super.initState();
    _diary = _getDiaryById();
  }

  Future<Map<String, dynamic>> _getDiaryById() async {
    final url = '${dotenv.env['BASE_URL']}/diary/${widget.diaryId}';
    final accessToken = await _authService.readAccessToken() ?? '';
    final response = await _authService.get(url, accessToken);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
      final diary = responseJson['res'][0];
      print(diary);
      return diary;
    } else {
      throw Exception('다이어리 상세 조회에 실패했습니다.');
    }
  }

  Future<void> _removeDiaryById() async {
    final url = '${dotenv.env['BASE_URL']}/diary/del?id=${widget.diaryId}';
    final accessToken = await _authService.readAccessToken() ?? '';
    final response = await _authService.delete(url, accessToken);

    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
        (route) => route == null,
      );
    } else {
      throw Exception('다이어리 삭제에 실패했습니다.');
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('일기 삭제'),
          content: const Text('정말 삭제 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                _removeDiaryById();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateDiaryPage(
                                diaryId: widget.diaryId,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          '수정',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: _showDeleteDialog,
                        child: const Text(
                          '삭제',
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
                        snapshot.data!['date'] ?? '2000-00-00',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
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
                          // TODO: 날씨 정보 표시 기능 구현
                        },
                        icon: const Icon(Icons.wb_sunny),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: 기분 정보 표시 기능 구현
                        },
                        icon: const Icon(Icons.emoji_emotions),
                      ),
                    ],
                  ),
                ),
                if (_imageURL.isNotEmpty)  // 이미지 URL이 있다면
                  Image.network(_imageURL),  // 이미지 표시
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: SingleChildScrollView(
                      child: Text(
                        snapshot.data!['content'] ?? '',
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
      floatingActionButton: Container(
        height: 40,
        width: 120,
        child: FloatingActionButton.extended(
          onPressed: _fetchImageURL,
          label: Text('이미지 생성'),
          backgroundColor: Colors.grey[300],
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
            side: BorderSide(color: Colors.grey),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }
}
