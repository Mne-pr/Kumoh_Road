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
          title: const Text('글쓰기', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 1,
          centerTitle: true,
        ),
        body: SafeArea(
          child: GestureDetector(
            // 키보드 외 화면 터치 시 키보드의 포커스를 해제하기 위함
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  photoInput(context),
                  formInput(),
                  SizedBox(
                    height: deviceHeight * 0.8,
                  )
                ],
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
                    content: Text('글쓰기 중')
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
                  const SnackBar(content: Text('글쓰기 완료')),
                );
                Navigator.of(context).pop();
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
    return Row(
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
    );
  }

  Widget formInput() {
    return Column(
      children: [
        Form(
            key: _formKey,
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: deviceHeight * 0.01),
                      child: const Text("제목",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    TextFormField(
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "제목",
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(width: 2, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey)),
                        border: OutlineInputBorder(
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
                        // 앞뒤 공백, 개행문자 제거
                        if (value == null || value.trim().isEmpty) {
                          return "제목을 입력해주세요";
                        }
                        if (value.length > 50) {
                          return "글자수를 초과했습니다";
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ],
            )),
        Form(
          key: _formKey2,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    bottom: deviceWidth * 0.01),
                child: const Text("내용",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextFormField(
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "내용",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(width: 2, color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(width: 1, color: Colors.grey)),
                  border: OutlineInputBorder(
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
                    return "글자수를 초과했습니다";
                  }
                  return null;
                },
              )
            ],
          ),
        )
      ],
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
