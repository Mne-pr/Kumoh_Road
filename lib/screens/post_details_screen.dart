import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/screens/main_screen.dart';
import 'package:kumoh_road/widgets/user_info_section.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utilities/image_picker_util.dart';

class PostDetailsScreen extends StatefulWidget {
  final TaxiScreenUserModel writerUserInfo;
  final TaxiScreenPostModel postInfo;

  const PostDetailsScreen({
    super.key,
    required this.writerUserInfo,
    required this.postInfo
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  String? _imagePath; // 촬영한 사진의 경로를 저장하는 변수

  @override
  Widget build(BuildContext context) {
    double currHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildButtonSection(context),
            _buildImageSection(context),
            Divider(),
            UserInfoSection(
              nickname: widget.writerUserInfo.nickname,
              imageUrl: widget.writerUserInfo.profileImageUrl,
              age: widget.writerUserInfo.age,
              gender: widget.writerUserInfo.gender,
              mannerTemperature: widget.writerUserInfo.mannerTemperature,
            ),
            Divider(),
            _buildPostContentSection(context),
            Divider(),
            _buildReviews(context),
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
              child: const Center(child: Text("출발 장소 촬영", style: TextStyle(fontWeight: FontWeight.bold),))),
        ],
      ),
    );
  }

  Widget _buildPostContentSection(BuildContext context){
    return Column(children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
          Padding(padding: const EdgeInsets.only(left: 10), child: Icon(Icons.title, color: Colors.grey)),
          Padding(padding: const EdgeInsets.only(left: 5), child: Text("제목", style: TextStyle(color: Colors.black26, fontSize: 18),)),
          Padding(padding: const EdgeInsets.only(left: 15), child: Text(widget.postInfo.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,))),],),),
        Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
          Padding(padding: const EdgeInsets.only(left: 10), child: Icon(Icons.watch_later_outlined, color: Colors.grey)),
          Padding(padding: const EdgeInsets.only(left: 5), child: Text("작성", style: TextStyle(color: Colors.black26, fontSize: 18),)),
          Padding(padding: const EdgeInsets.only(left: 15),child: Text("${widget.postInfo.createdTime.hour}시 ${widget.postInfo.createdTime.minute}분" , style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),],),),
        Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
          Padding(padding: const EdgeInsets.only(left: 10), child: Icon(Icons.touch_app_outlined, color: Colors.grey)),
          Padding(padding: const EdgeInsets.only(left: 5), child: Text("조회", style: TextStyle(color: Colors.black26, fontSize: 18),)),
          Padding(padding: const EdgeInsets.only(left: 15), child: Text("${widget.postInfo.viewCount}회", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),],),),
        SizedBox(height: 20,),
        Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [
          Padding(padding: const EdgeInsets.only(left: 15), child: Text(widget.postInfo.content, style: const TextStyle(fontSize: 18,),)),],),),],);
  }

  Widget _buildReviews(BuildContext context) {
    String name = widget.writerUserInfo.nickname;

    List<dynamic> reviewList = widget.writerUserInfo.reviewList;
    List<dynamic> displayReviewList = reviewList.length > 3 ? reviewList.sublist(reviewList.length - 3) : reviewList;
    List<Widget> reviewWidgetList = displayReviewList.map((review) =>
        Padding(padding: EdgeInsets.only(left: 15, top: 5, bottom: 5), child:
          Text(review, style: TextStyle(fontSize: 18))))
        .toList();

    return Column(children: [
      Padding(padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5), child: Text("$name님의 택시 합승 최근 리뷰", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      // Padding(padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5), child:
      //   Expanded(child: ListView(children: reviewWidgetList,)))
    ],);
  }

  // Widget _buildComments(BuildContext context) {}
  //
  // Widget _buildBottom(BuildContext context) {}
}