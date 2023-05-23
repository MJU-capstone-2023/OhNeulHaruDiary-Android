import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadPhotoPage extends StatefulWidget {
  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<UploadPhotoPage> {
  DateTime selectedDate = DateTime.now();
  List<XFile> images = []; // 선택된 이미지를 저장하는 리스트

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

  Future getImage() async {
    print("getImage");
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();

    setState(() {
      images.addAll(pickedImages);
      if (images.length > 10) {
        images = images.sublist(0, 10); // 이미지가 10장이 넘지 않도록 제한
      }
    });
  }

  Future<void> uploadImages() async {
    for (var image in images) {
      await uploadImage(File(image.path));
    }
  }

  Future<String> getUploadUrl(String imageName) async {
    final response = await http.put(
      Uri.parse('${dotenv.env['BASE_URL']}/diary/getS3Url'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['uploadUrl'];
    } else {
      throw Exception('이미지 업로드에 실패했습니다.');
    }
  }

  Future<void> uploadImage(File imageFile) async {
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    String uploadUrl = await getUploadUrl(p.basename(imageFile.path));
    var uri = Uri.parse(uploadUrl);

    var request = http.MultipartRequest("PUT", uri);
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: p.basename(imageFile.path));

    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      print("Image Uploaded");
    } else {
      print("Upload Failed");
    }
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
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
                    uploadImages(); // 이미지 s3에 업로드
                  },
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
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: images.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            text: '추가된 사진이 없어요!\n',
                            children: <TextSpan>[
                              TextSpan(text: '메신저 대화 사진을 업로드하면\n'),
                              TextSpan(text: '대신 일기를 써드려요'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      )
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: images.map((image) {
                          return Image.file(
                            File(image.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                        }).toList(),
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
