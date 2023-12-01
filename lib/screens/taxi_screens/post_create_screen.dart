import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../providers/user_providers.dart';
import '../../utilities/image_picker_util.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostCreateScreen extends StatefulWidget {
  final String collectionId;
  final String selectedTime;

  PostCreateScreen(this.collectionId, this.selectedTime, {super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;
  String _title = "";
  String _content = "";

  Widget photoInput(BuildContext context){
    Logger log = Logger(printer: PrettyPrinter());

    return Row(
      children: [
        InkWell(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(20)
            ),
            child: const Center(child: Icon(Icons.camera_alt))
          ),
          onTap: () async {
            if (await Permission.camera.request().isGranted) {
              final File? imageFile = await ImagePickerUtils.pickImageFromCamera();
              setState(() {
                _imagePath = imageFile?.path ?? "";
                log.i(_imagePath);
              });
            }
          },
        ),
        _imagePath != null ?
          Container(
            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(20)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(_imagePath!),
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.width * 0.2,
              ),
            ),
          ) : Container(),
      ],
    );
  }

  Widget formInput(){
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
                child: const Text(
                    "제목",
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "제목",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(width: 2, color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                          width: 1,
                          color: Colors.grey
                      )
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                onSaved: (value) {
                  setState(() {
                    _title = value!;
                  });
                },
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "제목을 입력해주세요";
                  }
                  return null;
                },
              )
            ],
          ),
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
                child: const Text(
                    "내용",
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
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
                      borderSide: BorderSide(
                          width: 1,
                          color: Colors.grey
                      )
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                onSaved: (value) {
                  setState(() {
                    _content = value!;
                  });
                },
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "내용을 입력해주세요";
                  }
                  return null;
                },
              )
            ],
          ),
        ],
      )
    );
  }

  Future<String> uploadImage(String imagePath) async {
    File image = File(imagePath);
    String imageName = imagePath.split('/').last;

    // Firebase Storage에 이미지 업로드
    Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null); // 업로드 완료까지 대기

    // 업로드된 이미지의 URL 가져오기
    String imageUrl = await storageReference.getDownloadURL();

    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('글쓰기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
        ),
      body: SafeArea(
        child: GestureDetector( // 키보드 외 화면 터치 시 키보드의 포커스를 해제하기 위함
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                photoInput(context),
                formInput()
                // titleInput(context, titleController),
                // contentInput(context, contentController, maxLine: 5)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.92,
        child: FloatingActionButton.extended(
          onPressed: () async {
            if(_formKey.currentState!.validate()){
              _formKey.currentState!.save();

              String imageUrl = "";
              if(_imagePath != null){
                imageUrl = await uploadImage(_imagePath!);
              }
              CollectionReference collectionReference = FirebaseFirestore.instance.collection(widget.collectionId);

              collectionReference.add({
                'imageUrl': imageUrl,
                'writerId': userProvider.id.toString(),
                'title': _title,
                'content': _content,
                'createdTime': DateTime.now(),
                'categoryTime': widget.selectedTime,
                'viewCount': 0,
                'commentList': <Map<String, String>>[],
                'memberList': <String>[],
                'visible': true
              });

              // TODO: 생성된 글 상세화면으로 이동하기(글 상세화면 구현 후)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('저장 완료')),
              );
            }
          },
          label: Text(
            '작성 완료',
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.2
            ),
          ),
        ),
      ),

    );
  }
}