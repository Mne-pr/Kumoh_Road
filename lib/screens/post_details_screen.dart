import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/main_screen.dart';
import 'package:kumoh_road/widgets/user_info_section.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utilities/image_picker_util.dart';

class PostDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? writerDetails;
  final Map<String, dynamic>? post;
  PostDetailsScreen({
    super.key,
    required this.writerDetails,
    required this.post
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  String? _imagePath; // 촬영한 사진의 경로를 저장하는 변수

  @override
  Widget build(BuildContext context) {
    String writerName = widget.writerDetails!['nickname'] ?? "이름 없음";
    String writerImageUrl = widget.writerDetails!['profileImageUrl'] ?? "assets/images/default_avatar.png";
    int writerAge = widget.writerDetails!['age'] ?? 20;
    String writerGender = widget.writerDetails!['gender'] ?? "성별 없음";
    double mannerTemperature = widget.writerDetails!['mannerTemperature'] ?? 0;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildButtonSection(context),
            _buildImageSection(context),
            UserInfoSection(
              nickname: writerName,
              imageUrl: writerImageUrl,
              age: writerAge,
              gender: writerGender,
              mannerTemperature: mannerTemperature,
            ),
            // _buildPostContentSection(context),
            // _buildViewCountSection(context)
            // _buildReviews(context),
            // _buildComments(context),
            // _buildBottom(context),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(onPressed: (){ Navigator.of(context).pop(); }, icon: const Icon(Icons.arrow_back_ios_outlined)),
        IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MainScreen(),
            ),
          );
        }, icon: const Icon(Icons.home_outlined)),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (await Permission.camera.request().isGranted) {
          final File? imageFile = await ImagePickerUtils.pickImageFromCamera();
          if (imageFile != null) {
            setState(() {
              _imagePath = imageFile.path;
            });
          }
        }
      },
      child: Column(
        children: [
          Center(
            child: _imagePath == null ? const Icon(Icons.camera_alt) : Image.file(
              File(_imagePath!),
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height / 3,
            ),
          ),
          Visibility(
              visible: _imagePath == null ? true : false,
              child: const Center(child: Text("사진 촬영"))),
        ],
      ),
    );
  }

  // Widget _buildUserInformation(BuildContext context) {}
  //
  // Widget _buildPost(BuildContext context) {}
  //
  // Widget _buildReviews(BuildContext context) {}
  //
  // Widget _buildComments(BuildContext context) {}
  //
  // Widget _buildBottom(BuildContext context) {}
}