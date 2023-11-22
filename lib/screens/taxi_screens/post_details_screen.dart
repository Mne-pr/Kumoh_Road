import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/screens/main_screens/main_screen.dart';
import 'package:kumoh_road/widgets/user_info_section.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utilities/image_picker_util.dart';
import '../../widgets/loding_indicator_widget.dart';

class PostDetailsScreen extends StatefulWidget {
  final TaxiScreenUserModel writerUserInfo;
  final TaxiScreenPostModel postInfo;

  const PostDetailsScreen(
      {super.key, required this.writerUserInfo, required this.postInfo});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  String? _imagePath; // 촬영한 사진의 경로를 저장하는 변수

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            FutureBuilder(
                future: _buildCommentSection(context),
                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: LoadingIndicatorWidget());
                  } else if (snapshot.hasError){
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Error : ${snapshot.error}'),
                            Text('Stack trace : ${snapshot.stackTrace}'),
                          ],
                        ),
                      );
                  }
                  else if (snapshot.hasData) {return snapshot.data!;}
                  else {return const Center(child: Text('No data available'));}
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_outlined)),
        IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
              );
            },
            icon: const Icon(Icons.home_outlined)),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;

    return InkWell(
        onTap: () async {
          if (await Permission.camera.request().isGranted) {
            final File? imageFile =
                await ImagePickerUtils.pickImageFromCamera();
            if (imageFile != null) {
              setState(() {
                _imagePath = imageFile.path;
              });
            }
          }
        },
        child: Column(
          children: [
            _imagePath == null ? const Icon(Icons.camera_alt) :
                Center(
                    child: Image.file(
                    File(_imagePath!),
                    height: MediaQuery.of(context).size.height / 5,
                    fit: BoxFit.cover,
                    ),
                ),
            Visibility(
                visible: _imagePath == null ? true : false,
                child: Center(
                    child: Text("출발 장소 촬영",
                        style: TextStyle(fontSize: defaultFontSize, fontWeight: FontWeight.bold),
                    ),
                ),
            ),
          ],
        ),
    );
  }

  Widget _buildPostContentSection(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    double leftPadding = screenWidth * 0.03;
    double topPadding = screenHeight * 0.005;

    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.title, color: Colors.grey),
              Padding(
                padding: EdgeInsets.only(left: leftPadding),
                child: Text(
                  "제목",
                  style: TextStyle(color: Colors.black26, fontSize: defaultFontSize),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: leftPadding),
                  child: Text(widget.postInfo.title,
                      style: TextStyle(
                        fontSize: defaultFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Row(
              children: [
                Icon(Icons.watch_later_outlined, color: Colors.grey),
                Padding(
                    padding: EdgeInsets.only(left: leftPadding),
                    child: Text(
                      "작성",
                      style: TextStyle(
                          color: Colors.black26,
                          fontSize: defaultFontSize
                      ),
                    ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: leftPadding),
                    child: Text(
                      "${widget.postInfo.createdTime.hour}시 ${widget.postInfo.createdTime.minute}분",
                      style: TextStyle(
                          fontSize: defaultFontSize, fontWeight: FontWeight.bold
                      ),
                    ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Row(
              children: [
                const Icon(Icons.touch_app_outlined, color: Colors.grey),
                Padding(
                    padding: EdgeInsets.only(left: leftPadding),
                    child: Text(
                      "조회",
                      style: TextStyle(color: Colors.black26, fontSize: defaultFontSize),
                    ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: leftPadding),
                    child: Text(
                      "${widget.postInfo.viewCount}회",
                      style: TextStyle(
                          fontSize: defaultFontSize, fontWeight: FontWeight.bold),
                    ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: leftPadding),
                    child: Text(
                      widget.postInfo.content,
                      style: TextStyle(
                        fontSize: defaultFontSize,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    double leftPadding = screenWidth * 0.03;
    double topPadding = screenHeight * 0.005;

    String name = widget.writerUserInfo.nickname;

    List<dynamic> mannerList = widget.writerUserInfo.mannerList;
    List<dynamic> unmannerList = widget.writerUserInfo.unmannerList;
    int mannerCnt = 0;
    int unmannerCnt = 0;
    for(int i = 0; i < mannerList.length; i++){
      int cnt1 = mannerList[i]["votes"];
      int cnt2 = unmannerList[i]["votes"];
      mannerCnt += cnt1;
      unmannerCnt += cnt2;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: leftPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$name님의 택시 합승 최근 리뷰",
              style: TextStyle(fontSize: defaultFontSize * 1.1, fontWeight: FontWeight.bold),
          ),
          Row(children: [
            const Text("매너 리뷰 "),
            Text("$mannerCnt개", style: const TextStyle(fontWeight: FontWeight.bold),)
          ],),
          Row(children: [
            const Text("비매너 리뷰 "),
            Text("$unmannerCnt개", style: const TextStyle(fontWeight: FontWeight.bold),)
          ],),
        ],
      ),
    );
  }

  Future<Widget> _buildCommentSection(BuildContext context) async {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    double leftPadding = screenWidth * 0.03;
    double topPadding = screenHeight * 0.005;

    ImageProvider backgroundImage = NetworkImage(widget.writerUserInfo.profileImageUrl);

    int cntComment = widget.postInfo.commentList.length;
    List<dynamic> commentList = widget.postInfo.commentList; //
    if(cntComment > 3){ // 최근 댓글 3개만 가져오도록
      commentList = widget.postInfo.commentList.sublist(cntComment - 3);
    }

    // 각각의 comment의 userId 값으로 사용자의 정보 리스트 (commentUserList)
    List<TaxiScreenUserModel> commentUserList = [];
    for(var comment in commentList){
      TaxiScreenUserModel commentUser = await TaxiScreenUserModel.getUserById(comment["userId"]);
      commentUserList.add(commentUser);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: leftPadding),
              child: Text("댓글",
                  style: TextStyle(fontSize: defaultFontSize * 1.1, fontWeight: FontWeight.bold)
              )
          ),
          Padding(
            padding: EdgeInsets.only(left: leftPadding),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: backgroundImage,
                  onBackgroundImageError: (_, __) {
                    setState(() {
                      backgroundImage =
                          const AssetImage('assets/images/default_avatar.png');
                    });
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: leftPadding),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "댓글 추가하기",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ),
            ],),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: (widget.postInfo.commentList.length < 4) ? widget.postInfo.commentList.length : 3,
              // commentList 와 commentUserList로 사용자 이미지, 사용자 이름, 댓글 내용 위젯 생성하기
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: leftPadding, right: leftPadding, top: topPadding),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(commentUserList[index].profileImageUrl),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(commentUserList[index].nickname, style: const TextStyle(fontWeight: FontWeight.bold),),
                            Padding(
                              padding: EdgeInsets.only(top: topPadding),
                              child: Text(commentList[index]["content"])
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // _buildBottomSection(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
  //     child: Row(
  //       children: [
  //         Column(
  //           children: [
  //             Text(),
  //             Text(data)
  //           ],
  //         ),
  //         ElevatedButton(onPressed: onPressed, child: child)
  //       ],
  //     ),
  //   );
  // }

// Widget _buildBottom(BuildContext context) {}
}
