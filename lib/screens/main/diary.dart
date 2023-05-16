import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Diary extends StatefulWidget {
  @override
  _DiaryState createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  late Future<List<Map<String, dynamic>>> _futureDiaries;

  @override
  void initState() {
    super.initState();
    _futureDiaries = _fetchDiaries();
  }

  Future<List<Map<String, dynamic>>> _fetchDiaries() async {
    final response = [
      {
        "year_month": "2023-01",
        "diaries": [
          {
            "id": 1,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          },
          {
            "id": 2,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          },
          {
            "id": 1,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          },
          {
            "id": 2,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          }
        ]
      },
      {
        "year_month": "2022-02",
        "diaries": [
          {
            "id": 7,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          },
          {
            "id": 8,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          },
          {
            "id": 9,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          },
          {
            "id": 10,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          },
          {
            "id": 9,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          }
        ]
      },
      {
        "year_month": "2020-11",
        "diaries": [
          {
            "id": 1,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          },
          {
            "id": 2,
            "image": "https://eco-cdn.iqpc.com/eco/images/channel_content/images/test.jpg"
          }
        ]
      }
    ];
    return await Future.delayed(const Duration(seconds: 1), () => response);


    // final response = await http.get(Uri.parse('${dotenv.env['BASE_URL']}!}/'),);
    // if (response.statusCode == 200) {
    //   final data = jsonDecode(response.body)['data'];
    //   return List<Map<String, dynamic>>.from(data);
    // } else {
    //   throw Exception('Failed to load diaries');
    // }
  }

  // 새로 고침
  Future<void> _refreshDiaries() async {
    setState(() {
      _futureDiaries = _fetchDiaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
        onRefresh: _refreshDiaries,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureDiaries,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final diaries = snapshot.data!;
                return ListView.builder(
                  itemCount: diaries.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: Text(
                            diaries[index]['year_month'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(5),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: diaries[index]['diaries'].length,
                          itemBuilder: (context, index2) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                diaries[index]['diaries'][index2]['image'],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                        if (index < diaries.length - 1) // 구분선
                          const Divider(
                            color: Colors.black12,
                            thickness: 1,
                            height: 20,
                          ),
                      ],
                    );
                  },
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
        )
      ),
    );
  }
}