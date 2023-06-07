import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sketch_day/screens/main/main_page.dart';

import '../../../../utils/authService.dart';

class UploadPhotoPage extends StatefulWidget {
  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<UploadPhotoPage> {
  DateTime selectedDate = DateTime.now();
  String summary = '';
  final _authService = AuthService();
  List<XFile> images = []; // 선택된 이미지를 저장하는 리스트

  // 이미지 삭제 다이얼로그
  Future<void> showDeleteDialog(int index) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: const Text('삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('아니요'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('예'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        images.removeAt(index);
      });
    }
  }

  // 이미지 UI
  Widget buildImage(File image, int index) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => showDeleteDialog(index),
            child: const Icon(
              Icons.remove_circle,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // 날짜 선택
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

  // 갤러리에서 이미지 선택
  Future getImage() async {
    print("getImage");
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();

    setState(() {
      images.addAll(pickedImages);
      if (images.length > 1) {
        images = images.sublist(0, 1); // 이미지가 1장이 넘지 않도록 제한 -> 추후 10장까지
      }
    });
  }

  // 이미지를 s3에 업로드
  Future<bool> uploadImages(List<XFile> images) async {
    try {
      List<String> imagePaths = images
          .map((image) => p.basename(File(image.path).path))
          .toList(); // 파일명 + 확장자 추출

      List<String> uploadUrls =
          await getUploadUrls(imagePaths); // 각 파일에 대한 presign url 요청

      for (int i = 0; i < images.length; i++) {
        // 이미지 업로드
        File imageFile = File(images[i].path);
        var fileBytes = await imageFile.readAsBytes();
        var uri = Uri.parse(uploadUrls[i]);
        print(uri);

        String fileType = p.extension(images[i].path).toLowerCase(); // 확장자 추출
        String contentType;

        switch (fileType) {
          case '.jpeg':
          case '.jpg':
            contentType = 'image/jpeg';
            break;
          case '.png':
            contentType = 'image/png';
            break;
          default:
            contentType = 'application/octet-stream'; // 미지원 확장자에 대한 기본값
        }

        var response = await http.put(
          uri,
          headers: {
            'Content-Type': contentType,
          },
          body: fileBytes,
        );

        if (response.statusCode == 200) {
          print('S3 이미지 업로드 성공');
          await getSummary(imagePaths); // async/await를 추가하여 getSummary의 완료를 기다림
        } else {
          Fluttertoast.showToast(msg: "이미지 업로드에 실패했습니다.");
          throw Exception('이미지 업로드에 실패했습니다.');
          return false; // false 반환 추가
        }
      }
      return true; // 모든 업로드가 성공하면 true를 반환
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> getSummary(List<String> imagePaths) async {
    print("일기 요약 요청");
    final url = '${dotenv.env['BASE_URL']}/diary/uploadImg';
    final accessToken = await _authService.readAccessToken() ?? '';

    List<String> imageUrls = imagePaths.map((imageUrl) {
      return '${dotenv.env['AWS_S3']}/$imageUrl';
    }).toList();

    final response = await _authService.post(
      url,
      accessToken,
      body: {
        'date': selectedDate.toIso8601String().split('T')[0],
        'emo_id': "1",
        'wea_id': "1",
        's3_urls': imageUrls
      },
    );
    print(jsonDecode(utf8.decode(response.bodyBytes)));

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MainPage(),
        ),
      );
      Fluttertoast.showToast(msg: "일기 생성에 성공하였습니다.");
    } else {
      Fluttertoast.showToast(msg: "일기 생성에 실패하였습니다.");
      throw Exception('일기 생성에 실패했습니다.');
    }
  }

  void nextButtonPressed() {
    if (images.isEmpty) {
      Fluttertoast.showToast(
        msg: "이미지를 선택해주세요.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("이미지 업로드 중..."),
                )
              ],
            ),
          );
        },
      );

      uploadImages(images).then((success) {
        Navigator.of(context).pop(); // 로딩 다이얼로그를 제거

        if (!success) {
          Fluttertoast.showToast(msg: "이미지 업로드에 실패했습니다.");
        }
      });
    }
  }

  Future<List<String>> getUploadUrls(List<String> imagePaths) async {
    // presign url 요청
    print(imagePaths);
    final url = '${dotenv.env['BASE_URL']}/diary/getS3Url';
    final accessToken = await _authService.readAccessToken() ?? '';
    final response = await _authService
        .put(url, accessToken, body: {"imagePaths": imagePaths});

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      return List<String>.from(data['s3_url']); // url 리스트를 반환
    } else {
      Fluttertoast.showToast(msg: "이미지 업로드 URL 통신에 실패했습니다.");
      throw Exception('이미지 업로드에 실패했습니다.');
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
                  onPressed: nextButtonPressed,
                  child: const Text(
                    '다음',
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
                const SizedBox(width: 10.0),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  height: 400,
                  child: images.isEmpty
                      ? Image.asset(
                          'assets/images/no_messenger_img.png',
                          fit: BoxFit.cover,
                        )
                      : GridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          children: List.generate(images.length, (index) {
                            return buildImage(File(images[index].path), index);
                          }),
                        ),
                ),
              ),
              ElevatedButton(
                onPressed: getImage,
                child: const Text('이미지 선택'),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: const Text('최대 10장까지 업로드 할 수 있어요'),
              )
            ],
          )
        ],
      ),
    );
  }
}
