import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../providers/user_providers.dart';
import '../../utilities/image_picker_util.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Logger log = Logger(printer: PrettyPrinter());
late UserProvider currUser;
late double deviceWidth;
late double deviceHeight;
late double deviceFontSize;
late Color mainColor;

class PostCreateScreen extends StatefulWidget {
  final String collectionId;
  final String selectedTime;

  PostCreateScreen(this.collectionId, this.selectedTime, {super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String? _imagePath;
  String _title = "";
  String _content = "";

  @override
  Widget build(BuildContext context) {
    currUser = Provider.of<UserProvider>(context, listen: false);
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    deviceFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    mainColor = Theme.of(context).primaryColor;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('합승 게시글 작성', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 1,
          centerTitle: true,
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // 전체 패딩 추가
                child: Column(
                  children: [
                    photoInput(context),
                    formInput(),
                    SizedBox(height: deviceHeight * 0.8),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: deviceWidth * 0.92,
          child: FloatingActionButton.extended(
            onPressed: () async {
              if (_formKey.currentState!.validate() &&
                  _formKey2.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('게시글 작성 중')
                  ),
                );
                _formKey.currentState!.save();
                _formKey2.currentState!.save();
                String imageUrl = "";
                if (_imagePath != null) {
                  imageUrl = await uploadImage(_imagePath!);
                }
                CollectionReference collectionReference = FirebaseFirestore.instance.collection(widget.collectionId);
                log.i("_content : $_content");
                collectionReference.add({
                  'imageUrl': imageUrl,
                  'writerId': currUser.id.toString(),
                  'title': _title,
                  'content': _content,
                  'createdTime': DateTime.now(),
                  'categoryTime': widget.selectedTime,
                  'viewCount': 0,
                  'commentList': <Map<String, String>>[],
                  'memberList': <String>[],
                  'visible': true
                });
                int newPostCount = currUser.postCount + 1;
                await currUser.updateUserInfo(postCount: newPostCount);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시글 작성 완료')),
                );
                Navigator.of(context).pop();
                setState(() { });
              }
            },
            label: Text(
              '작성 완료',
              style: TextStyle(
                fontSize: deviceFontSize * 1.2),
            ),
          ),
        ));
  }

  Widget photoInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Text(
            "현재 위치를 인증해주세요:\n기차 내부 사진, 버스 내부 사진, 학교 사진..",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: deviceFontSize * 1.2),
          ),
        ),
        Row(
          children: [
            InkWell(
              child: Container(
                  width: deviceWidth * 0.2,
                  height: deviceWidth * 0.2,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Icon(Icons.camera_alt))),
              onTap: () async {
                if (await Permission.camera.request().isGranted) {
                  final File? imageFile =
                  await ImagePickerUtils.pickImageFromCamera();
                  setState(() {
                    _imagePath = imageFile?.path ?? "";
                  });
                }
              },
            ),
            _imagePath != null
                ? Container(
              margin: EdgeInsets.only(
                  left: deviceWidth * 0.04),
              width: deviceWidth * 0.2,
              height: deviceWidth * 0.2,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                  width: deviceWidth * 0.2,
                  height: deviceWidth * 0.2,
                ),
              ),
            )
                : Container(),
          ],
        ),
      ],
    );
  }


  Widget formInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "합승 게시글 제목",
            style: TextStyle(fontSize: deviceFontSize * 1.2),
          ),
        ),
        Form(
          key: _formKey,
          child: TextFormField(
            maxLines: 2,
            style: TextStyle(fontSize: deviceFontSize * 1.1),
            decoration: InputDecoration(
              hintText: "참여자들을 위해 최대한 자세한 제목을 작성해주세요!\n(최대 50자)",
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 2, color: mainColor),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.grey),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            onSaved: (value) {
              _title = value!;
            },
            onChanged: (value) {
              _formKey.currentState!.validate();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
              return "제목을 입력해주세요";
              }
              if (value.length > 50) {
              return "제목은 최대 50자까지 가능합니다";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            "합승 게시글 내용",
            style: TextStyle(fontSize: deviceFontSize * 1.2),
          ),
        ),
        Form(
          key: _formKey2,
          child: TextFormField(
            maxLines: 5,
            style: TextStyle(fontSize: deviceFontSize * 1.1),
            decoration: InputDecoration(
              hintText: "참여자들을 위해 최대한 자세한 내용을 작성해주세요!\n(최대 100자)", // 힌트 텍스트에 정보 포함
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 2, color: mainColor),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.grey),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            onSaved: (value) {
              _content = value!;
            },
            onChanged: (value) {
              _formKey2.currentState!.validate();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
              return "내용을 입력해주세요";
              }
              if (value.length > 100) {
              return "내용은 최대 100자까지 가능합니다";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }


  Widget inputFieldContainer(String label, Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: deviceHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: deviceFontSize * 1.2),
          ),
          SizedBox(height: deviceHeight * 0.01),
          child,
        ],
      ),
    );
  }

  Future<String> uploadImage(String imagePath) async {
    File image = File(imagePath);
    String imageName = imagePath.split('/').last;

    // Firebase Storage에 이미지 업로드
    Reference storageReference =
        FirebaseStorage.instance.ref().child('images/$imageName');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null); // 업로드 완료까지 대기

    // 업로드된 이미지의 URL 가져오기
    String imageUrl = await storageReference.getDownloadURL();

    return imageUrl;
  }


}
