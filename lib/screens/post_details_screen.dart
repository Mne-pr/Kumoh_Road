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
            const Divider(),
            UserInfoSection(
              nickname: widget.writerUserInfo.nickname,
              imageUrl: widget.writerUserInfo.profileImageUrl,
              age: widget.writerUserInfo.age,
              gender: widget.writerUserInfo.gender,
              mannerTemperature: widget.writerUserInfo.mannerTemperature,
            ),
            const Divider(),
            _buildPostContentSection(context),
            const Divider(),
            _buildReviewSection(context),
            const Divider(),
            _buildCommentSection(context),
            _buildBottomSection(context),
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
          _imagePath == null ? const Icon(Icons.camera_alt) : Center(child: Image.file(File(_imagePath!), height: MediaQuery.of(context).size.height / 5, fit: BoxFit.cover,)),
          Visibility(
              visible: _imagePath == null ? true : false,
              child: const Center(child: Text("출발 장소 촬영", style: TextStyle(fontWeight: FontWeight.bold),))),
        ],
      ),
    );
  }

  Widget _buildPostContentSection(BuildContext context){
    double fontSize = 16.0;
    double verticalSize = 3;
    return Column(children: [
      Row(children: [
        Padding(padding: const EdgeInsets.only(left: 10), child: Icon(Icons.title, color: Colors.grey)),
        Padding(padding: const EdgeInsets.only(left: 5), child: Text("제목", style: TextStyle(color: Colors.black26, fontSize: fontSize),)),
        Padding(padding: const EdgeInsets.only(left: 15), child: Text(widget.postInfo.title, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold,))),],),
      Padding(padding: EdgeInsets.only(top: verticalSize), child: Row(children: [
        Padding(padding: const EdgeInsets.only(left: 10), child: Icon(Icons.watch_later_outlined, color: Colors.grey)),
        Padding(padding: const EdgeInsets.only(left: 5), child: Text("작성", style: TextStyle(color: Colors.black26, fontSize: fontSize),)),
        Padding(padding: const EdgeInsets.only(left: 15),child: Text("${widget.postInfo.createdTime.hour}시 ${widget.postInfo.createdTime.minute}분" , style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),)),],),),
      Padding(padding: EdgeInsets.only(top: verticalSize), child: Row(children: [
        Padding(padding: const EdgeInsets.only(left: 10), child: Icon(Icons.touch_app_outlined, color: Colors.grey)),
        Padding(padding: const EdgeInsets.only(left: 5), child: Text("조회", style: TextStyle(color: Colors.black26, fontSize: fontSize),)),
        Padding(padding: const EdgeInsets.only(left: 15), child: Text("${widget.postInfo.viewCount}회", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),)),],),),
      SizedBox(height: 10,),
      Padding(padding: EdgeInsets.only(top: verticalSize), child: Row(children: [
        Padding(padding: const EdgeInsets.only(left: 15), child: Text(widget.postInfo.content, style: TextStyle(fontSize: fontSize,),)),],),),],);
  }

  Widget _buildReviewSection(BuildContext context) {
    String name = widget.writerUserInfo.nickname;

    List<dynamic> reviewList = widget.writerUserInfo.reviewList;
    List<dynamic> displayReviewList = reviewList.length > 3 ? reviewList.sublist(reviewList.length - 3) : reviewList;
    List<Widget> reviewWidgetList = displayReviewList.map((review) => Text(review, style: TextStyle(fontSize: 17))).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5), child: Text("$name님의 택시 합승 최근 리뷰", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      Padding(padding: const EdgeInsets.only(left: 15, top: 5, bottom: 5), child:
        ListView(
          shrinkWrap: true,
          children: reviewWidgetList))]);
  }

  Widget _buildCommentSection(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("댓글", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)  ),
          _buildCommentInputField(context),
          Expanded(child:
            ListView.builder(itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("2"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCommentInputField(BuildContext context) {
    TextEditingController _commentController = TextEditingController();

    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Write a comment...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {

          }
        ),
      ],
    );
  }

  _buildBottomSection(BuildContext context) {
    return Container(child: Row(children: [
      Column(children: [
        Text("참여인원 ${widget.postInfo.membersIdList.length + 1}/4"),
        Text("남성만 참여 가능"),
      ],),
      FilledButton(onPressed: (){}, child: Text("합승하기"))
    ],),);
  }

  // Widget _buildBottom(BuildContext context) {}
}