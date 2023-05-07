import 'package:flutter/material.dart';
import 'package:sketch_day/screens/main/create_post/upload_photo_page.dart';
import 'package:sketch_day/screens/main/diary.dart';
import 'package:sketch_day/screens/main/mypage.dart';

import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/floating_action_button.dart';
import 'create_post/write_diary_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [Diary(), const Mypage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[100],
        leadingWidth: 140, // 앱바의 leading 영역의 너비를 변경
        leading: Padding(
          padding: const EdgeInsets.only(left: 15), // 좌측 여백 추가
          child: SizedBox(
            child: Image.asset('images/logo_v3.png',),
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('글쓰기'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WriteDiaryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('사진 업로드'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadPhotoPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
