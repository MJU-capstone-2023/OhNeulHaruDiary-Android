import 'package:flutter/material.dart';
import 'package:sketch_day/screens/main/create_post/with_image/upload_photo_page.dart';
import 'package:sketch_day/screens/main/user_diary/diary.dart';
import 'package:sketch_day/screens/main/user_page/mypage.dart';

import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/floating_action_button.dart';
import 'create_post/without_image/write_diary_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [Diary(), Mypage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[100],
        leadingWidth: 140,
        // 앱바의 leading 영역의 너비를 변경
        leading: Padding(
          padding: const EdgeInsets.only(left: 15), // 좌측 여백 추가
          child: SizedBox(
            child: Image.asset(
              'assets/images/logo_v3.png',
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButtonWidget(
        icon: Icons.add,
        onPressed: _onFloatingActionButtonPressed,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onFloatingActionButtonPressed() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 200.0,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black54,
                    ),
                  ),
                  const Text(
                    '일기 쓰기',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24.0),
                ],
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WriteDiaryPage(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black54,
                            size: 40.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '글쓰기',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadPhotoPage(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Icon(
                            Icons.photo,
                            color: Colors.black54,
                            size: 40.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '사진 업로드',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
