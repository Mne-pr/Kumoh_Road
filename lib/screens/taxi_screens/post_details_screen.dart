import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:kumoh_road/screens/main_screens/main_screen.dart';
import 'package:kumoh_road/screens/taxi_screens/review_screen.dart';
import 'package:kumoh_road/screens/user_info_screens/other_user_info_screen.dart';
import 'package:kumoh_road/utilities/url_launcher_util.dart';
import 'package:kumoh_road/widgets/user_info_section.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../utilities/report_manager.dart';

Logger log = Logger(printer: PrettyPrinter());
UserProvider? currUser;
late double deviceWidth;
late double deviceHeight;
late double deviceFontSize;
late Color mainColor;

class PostDetailsScreen extends StatefulWidget {
  final TaxiScreenUserModel writer;
  final TaxiScreenPostModel post;
  final String collectionName;

  const PostDetailsScreen(
      {super.key,
      required this.writer,
      required this.post,
      required this.collectionName});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> with WidgetsBindingObserver{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  String _content = "";
  bool _showBottomSection = true;
  bool _showMemberSection = true;
  late List<dynamic> _commentList;
  late List<dynamic> _memberList;
  late final ReportManager _reportManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ReviewScreen(writerId: widget.writer.userId, writerName: widget.writer.nickname,);
      },));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _commentList = widget.post.commentList;
    _memberList = widget.post.memberList;

    if(currUser == null){
      currUser = Provider.of<UserProvider>(context);
      currUser!.startListeningToUserChanges();
      _reportManager = ReportManager(currUser!);
    }

    if(currUser!.id == null) {
      // 현재 사용자 ID가 없는 경우, 첫 번째 화면으로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    currUser = Provider.of<UserProvider>(context, listen: false);
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    deviceFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    mainColor = Theme.of(context).primaryColor;

    bool isWriter = currUser!.id.toString() == widget.writer.userId;
    bool isMember = widget.post.memberList.contains(currUser!.id.toString());

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _showBottomSection = true;
                _showMemberSection = true;
              });
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopSection(),
                  UserInfoSection(
                    nickname: widget.writer.nickname,
                    imageUrl: widget.writer.profileImageUrl,
                    age: widget.writer.age,
                    gender: widget.writer.gender,
                    mannerTemperature: widget.writer.mannerTemperature,
                  ),
                  const Divider(),
                  _buildPostContentSection(context),
                  const Divider(),
                  _buildReviewSection(context),
                  const Divider(),

                  // ,

                  FutureBuilder(
                    future: _buildCommentSection(context),
                    builder:
                        (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.hasError) {
                        log.e(snapshot.error);
                        log.e(snapshot.stackTrace);
                        return const Center(
                          child: Text("댓글 로딩 실패"),
                        );
                      } else if (snapshot.hasData) {
                        return snapshot.data!;
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  SizedBox(
                    height: deviceHeight * 0.8,
                  )
                ],
              ),
            ),
          ),
          (isWriter || isMember) && _showMemberSection
              ? FutureBuilder(
                  future: _buildMemberListSection(context),
                  builder:
                      (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                    if (snapshot.hasError) {
                      log.e(snapshot.error);
                      log.e(snapshot.stackTrace);
                      return const Center(
                        child: Text("댓글 로딩 실패"),
                      );
                    } else if (snapshot.hasData) {
                      return snapshot.data!;
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                )
              : Container(),
          _showBottomSection ? _buildBottomSection(context) : Container(),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Stack(
      children: [
        _buildImageSection(context),
        Positioned(
          left: 0,
          right: 0,
          top: deviceHeight * 0.04,
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_outlined,
                    color: Colors.white,
                  )),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget imageWidget(String imageUrl, BuildContext context) {
    return imageUrl.isEmpty
        ? Image.asset(
            'assets/images/default_avatar.png',
            width: deviceWidth,
            height: deviceWidth * 0.8,
            fit: BoxFit.cover,
          )
        : Image.network(
            widget.post.imageUrl,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              return child;
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
            width: deviceWidth,
            height: deviceWidth * 0.8,
            fit: BoxFit.cover,
          );
  }

  Widget _buildImageSection(BuildContext context) {
    return imageWidget(widget.post.imageUrl, context);
  }

  Widget _buildPostContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title,
          style: TextStyle(
            fontSize: deviceFontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${DateTime.now().difference(widget.post.createdTime).inMinutes}분전",
          style: const TextStyle(color: Colors.grey),
        ),
        Text(widget.post.content),
        Text(
          "조회 ${widget.post.viewCount}회",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    double defaultFontSize = deviceFontSize;
    // 매너와 언매너 리스트 합치기
    List<Map<String, dynamic>> reviewList = widget.writer.mannerList!
        .followedBy(widget.writer.unmannerList!)
        .toList();
    reviewList.sort((a, b) => b["votes"].compareTo(a["votes"]));
    List<Map<String, dynamic>> showList = reviewList.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${widget.writer.nickname}님의 택시 합승 최근 리뷰",
          style: TextStyle(
              fontSize: defaultFontSize * 1.2, fontWeight: FontWeight.bold),
        ),
        Text("${showList[0]['content']}"),
        Text("${showList[1]['content']}"),
        Text("${showList[2]['content']}"),
      ],
    );
  }

  Future<Widget> _buildCommentSection(BuildContext context) async {
    List<dynamic> commentList = _commentList;

    if (widget.post.commentList.length > 3) {
      commentList = widget.post.commentList.sublist(widget.post.commentList.length - 3);
    }

    commentList.sort((comment1, comment2) {
      DateTime time1 = (comment1['time'] as Timestamp).toDate();
      DateTime time2 = (comment2['time'] as Timestamp).toDate();
      return time2.compareTo(time1);
    });

    List<String> commentUserIdList = commentList.map((e) => e['user_code'] as String).toList();
    List<TaxiScreenUserModel> commentUserList =  await TaxiScreenUserModel.getCommentUserList(commentUserIdList);

    for(var e in commentUserList){
      log.i(e.userId);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("댓글",
            style: TextStyle(
                fontSize: deviceFontSize * 1.2, fontWeight: FontWeight.bold)),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(currUser!.profileImageUrl!),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "댓글 작성하기",
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    border: UnderlineInputBorder(),
                  ),
                  onSaved: (value) {
                    setState(() {
                      _content = value!;
                    });
                  },
                  onTap: () {
                    setState(() {
                      _showMemberSection = false;
                      _showBottomSection = false;
                    });
                  },
                  onChanged: (value) {
                    _formKey.currentState!.validate();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      //빈 칸만 입력, 엔터만 입력했을 경우도 빈 내용이라고 감지
                      return "내용을 입력해주세요";
                    }
                    if (value.length > 40) {
                      return "글자수를 초과했습니다";
                    }
                    return null;
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  DateTime now = DateTime.now();
                  _formKey.currentState!.save();
                  // DB에 댓글 정보 저장
                  try {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference collection =
                        firestore.collection(widget.collectionName);
                    QuerySnapshot querySnapshot = await collection
                        .where('createdTime',
                            isEqualTo: widget.post.createdTime)
                        .get();
                    var doc = querySnapshot.docs.first;
                    var commentList = doc['commentList'] as List<dynamic>;
                    var newComment = {
                      'user_code': currUser!.id.toString(),
                      'comment': _content,
                      'time': now,
                      'enable': true
                    };
                    commentList.add(newComment);
                    await collection
                        .doc(doc.id)
                        .update({'commentList': commentList});
                    int newPostCommentCnt = currUser!.postCommentCount + 1;
                    currUser!.updateUserInfo(
                        postCommentCount: newPostCommentCnt);

                    FocusScope.of(context).unfocus();
                    setState(() {
                      _commentList.add({
                        'user_code': currUser!.id.toString(),
                        'comment': _content,
                        'time': Timestamp.fromDate(now),
                        'enable': true
                      });
                      _controller.clear();
                      _showBottomSection = true;
                      _showMemberSection = true;
                    });
                  } on Exception catch (error) {
                    log.e(error);
                  }
                }
              },
              icon: const Icon(Icons.send),
              color: Colors.grey,
            )
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: commentList.length,
          itemBuilder: (context, index) {
            return commentItem(context, commentList[index] as Map<String, dynamic>, commentList.length - index, commentUserList[index]);
          },
        ),
      ],
    );
  }

  Widget commentItem(BuildContext context, Map<String, dynamic> comment, int commentIndex, TaxiScreenUserModel user) {
    DateTime writeTime = (comment['time'] as Timestamp).toDate();
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.profileImageUrl),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이름, 시간(mm분전)
            Row(
              children: [
                user.userId == widget.writer.userId
                    ? Text(
                  "${user.nickname} (방장)",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
                    : Text(user.nickname),
                Padding(
                  padding: EdgeInsets.only(left: deviceWidth * 0.02),
                  child: Text(
                    "${DateTime.now().difference(writeTime).inMinutes}분전",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            Text(comment['comment'])
          ],
        ),
        const Spacer(),
        user.userId != currUser!.id.toString()
        ? PopupMenuButton(
          itemBuilder: (context) {
            return [
              reportMenuItem(commentIndex, comment["user_code"], comment["comment"])
            ];
          },
          icon: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.more_vert)
          ),
        )
        : Container(),
      ],
    );
  }
  
  PopupMenuItem<String> reportMenuItem(int commentIndex, String reportedUserId, String commentContent) {
    return PopupMenuItem<String>(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              content: const Text("신고하시겠습니까?"),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("아니요")
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent
                    ),
                    onPressed: () async {
                      String docId = "";
                      try{
                        docId = await TaxiScreenPostModel.getDocId(
                            collectionId: widget.collectionName,
                            writerId: widget.writer.userId,
                            createdTime: widget.post.createdTime
                        );
                      }on Exception catch(e){
                        log.e("문서 id 찾기 실패", error: e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('신고 처리 실패')),
                        );
                        return;
                      }
                      
                      _reportManager.reportPostComment(
                        postCommentId: "${widget.collectionName}-$docId-$commentIndex",
                        reason: commentContent,
                        category: "",
                        reportedUserId: reportedUserId
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고 처리가 되었습니다')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("네")
                ),
              ],
            );
          },
        );
      },
      child: const Text("신고하기"),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: deviceHeight * 0.05,
        color: Colors.grey.shade50,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "정원 4명중 ${_memberList.length + 1}명 참여중",
                  style: TextStyle(
                      fontSize: deviceFontSize * 1.2, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${widget.writer.gender}만 참여가능",
                  style: TextStyle(fontSize: deviceFontSize, color: Colors.grey),
                )
              ],
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  bool isWriter = widget.writer.userId == currUser!.id.toString();
                  if (isWriter) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미 합승중입니다'), duration: Duration(seconds: 1)),
                    );
                    return;
                  }
                  if (_memberList.contains(currUser!.id.toString())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미 합승중입니다'), duration: Duration(seconds: 1)),
                    );
                    return;
                  }
                  if (_memberList.length >= 3){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('정원 초과입니다'), duration: Duration(seconds: 1)),
                    );
                    return;
                  }

                  bool sameGender = widget.writer.gender == currUser!.gender;
                  if (!sameGender) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${widget.writer.gender}만 참여 가능합니다')),
                    );
                    return;
                  }
                  try {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference collection =
                        firestore.collection(widget.collectionName);
                    QuerySnapshot querySnapshot = await collection
                        .where('createdTime',
                            isEqualTo: widget.post.createdTime)
                        .get();
                    var doc = querySnapshot.docs.first;
                    var commentList = doc['memberList'] as List<dynamic>;
                    commentList.add(currUser!.id.toString());
                    await collection
                        .doc(doc.id)
                        .update({'memberList': commentList});
                  } on Exception catch (e) {
                    log.e(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('합승 실패')),
                    );
                  }
                  setState(() {
                    _memberList.add(currUser!.id.toString());
                    _showMemberSection = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('합승 완료')),
                  );
                },
                child: widget.writer.userId == currUser!.id.toString() ||
                        _memberList.contains(currUser!.id.toString())
                    ? const Text("합승중")
                    : const Text("합승하기"))
          ],
        ),
      ),
    );
  }

  Row memberListItem(BuildContext context, TaxiScreenUserModel user, String role, Widget buttonArea) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if(currUser!.id.toString() == user.userId) { return; }

            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OtherUserProfileScreen(userId: user.userId),
            ));
          },
          child: CircleAvatar(
            backgroundImage: NetworkImage(user.profileImageUrl),
          ),
        ),
        Text(
          user.nickname,
          style:
              TextStyle(fontSize: deviceFontSize * 1.1, fontWeight: FontWeight.bold),
        ),
        Text(
          " $role",
          style: const TextStyle(color: Colors.grey),
        ),
        const Spacer(),
        buttonArea
      ],
    );
  }

  Future<Widget> _buildMemberListSection(BuildContext context) async {
    List<String> memberIdList = _memberList.map((e) => e as String).toList();
    List<TaxiScreenUserModel> memberList =
        await TaxiScreenUserModel.getUserList(memberIdList);
    bool isWriter = widget.post.writerId == currUser!.id.toString();
    List<Widget> listView = [];
    if (isWriter) {
      listView.add(memberListItem(context, widget.writer, "방장", Container()));
      for (var e in memberList) {
        listView
            .add(memberListItem(context, e, "참여자", kickOutButton(e.userId)));
      }
    } else {
      // 참여자일 경우
      listView.add(memberListItem(context, widget.writer, "방장", wireButton()));
      for (var e in memberList) {
        listView.add(memberListItem(context, e, "참여자", Container()));
      }
    }

    return DraggableScrollableSheet(
        initialChildSize: 0.4, // 나타나는 크기
        builder: (BuildContext context2, ScrollController controller) {
          return Container(
            height: deviceHeight * 0.4,
            decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ]),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "참여자",
                          style: TextStyle(
                              fontSize: deviceFontSize * 1.1,
                              fontWeight: FontWeight.bold),
                        )
                      ]),
                ),
                Expanded(
                  child: ListView(
                    children: listView,
                  ),
                ),
              ],
            ),
          );
        });
  }

  ElevatedButton kickOutButton(String kickId) {
    return ElevatedButton(
      onPressed: () async {
        try {
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          CollectionReference collection =
              firestore.collection(widget.collectionName);
          QuerySnapshot querySnapshot = await collection
              .where('createdTime', isEqualTo: widget.post.createdTime)
              .get();
          var doc = querySnapshot.docs.first;
          var temp = doc['memberList'] as List<dynamic>;
          List<String> newMemberList = temp.map((e) => e as String).toList();
          newMemberList.remove(kickId);
          await collection.doc(doc.id).update({'memberList': newMemberList});
          setState(() {
            _memberList = newMemberList;
          });
        } on Exception catch (e) {
          log.e(e);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('추방하기 실패')),
          );
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
      child: const Text("추방하기"),
    );
  }

  //송금 버튼
  ElevatedButton wireButton() {
    return ElevatedButton(
      onPressed: () {
        try {
          launchURL(widget.writer.qrCodeUrl!);
        } catch (e) {
          log.e(e);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('송금 실패')),
          );
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: mainColor),
      child: const Text("송금하기"),
    );
  }

  void kickOut(String kickId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference collection =
          firestore.collection(widget.collectionName);
      QuerySnapshot querySnapshot = await collection
          .where('createdTime', isEqualTo: widget.post.createdTime)
          .get();
      var doc = querySnapshot.docs.first;
      var temp = doc['memberList'] as List<dynamic>;
      List<String> newMemberList = temp.map((e) => e as String).toList();
      newMemberList.remove(kickId);
      await collection.doc(doc.id).update({'memberList': newMemberList});
      setState(() {
        _memberList = newMemberList;
      });
    } on Exception catch (e) {
      log.e(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('추방하기 실패')),
      );
    }
  }
}
