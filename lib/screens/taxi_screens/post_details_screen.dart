import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/main.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:kumoh_road/screens/main_screens/main_screen.dart';
import 'package:kumoh_road/utilities/url_launcher_util.dart';
import 'package:kumoh_road/widgets/user_info_section.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

Logger log = Logger(printer: PrettyPrinter());
late double width;
late double height;
late double fontSize;
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

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late final GlobalKey<FormState> _formKey;
  late final FocusNode inputFocusNode;
  late final TextEditingController _controller;
  String _content = "";
  bool _showBottomSection = true;
  bool _showMemberSection = true;
  late List<dynamic> _commentList;
  late List<dynamic> _memberList;
  late UserProvider currUser;

  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey<FormState>();
    inputFocusNode = FocusNode();
    _controller = TextEditingController();
    _commentList = widget.post.commentList;
    _memberList = widget.post.memberList;
    inputFocusNode.addListener(() {
      if (inputFocusNode.hasFocus) {
        setState(() {
          _showBottomSection = false;
          _showMemberSection = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    currUser = Provider.of<UserProvider>(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    fontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    mainColor = Theme.of(context).primaryColor;
    bool isWriter = currUser.id.toString() == widget.writer.userId;
    bool isMember = widget.post.memberList.contains(currUser.id.toString());

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
                  FutureBuilder(
                    future: _buildCommentSection(context),
                    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
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
                ],
              ),
            ),
          ),
          (isWriter || isMember) && _showMemberSection
            ? FutureBuilder(
              future: _buildMemberListSection(context),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
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
          ) : Container(),
          _showBottomSection
            ? _buildBottomSection(context) : Container(),
        ],
      ),
    );
  }

  PopupMenuItem<String> menuItem(String menuText) {
    return PopupMenuItem<String>(
        onTap: () {
          //todo: 신고 페이지로 이동
        },
        child: Text(menuText));
  }

  Widget _buildTopSection() {
    return Stack(
      children: [
        _buildImageSection(context),
        Positioned(
          left: 0,
          right: 0,
          top: height * 0.04,
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
              const Spacer(),
              PopupMenuButton<String>(
                color: Colors.white,
                itemBuilder: (context) {
                  return [menuItem("신고하기")];
                },
              ),
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
            width: width,
            height: width,
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
            width: width,
            height: width,
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
            fontSize: fontSize * 1.2,
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
    double defaultFontSize = fontSize;
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
    UserProvider user = Provider.of<UserProvider>(context);

    List<dynamic> commentList = _commentList;
    if (widget.post.commentList.length > 3) {
      commentList =
          widget.post.commentList.sublist(widget.post.commentList.length - 3);
    }
    commentList.sort((comment1, comment2) {
      DateTime time1 = (comment1['time'] as Timestamp).toDate();
      DateTime time2 = (comment2['time'] as Timestamp).toDate();
      return time2.compareTo(time1);
    });
    List<String> commentUserIdList =
        commentList.map((e) => e['user_code'] as String).toList();
    List<TaxiScreenUserModel> commentUserList =
        await TaxiScreenUserModel.getCommentUserList(commentUserIdList);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("댓글",
            style: TextStyle(
                fontSize: fontSize * 1.2,
                fontWeight: FontWeight.bold)),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(user.profileImageUrl!),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _controller,
                  focusNode: inputFocusNode,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "내용을 입력해주세요";
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
                      'user_code': user.id.toString(),
                      'comment': _content,
                      'time': now,
                      'enable': true
                    };
                    commentList.add(newComment);
                    await collection
                        .doc(doc.id)
                        .update({'commentList': commentList});
                    int newPostCommentCnt = currUser.postCommentCount + 1;
                    currUser.updateUserInfo(postCommentCount: newPostCommentCnt);

                    FocusScope.of(context).unfocus();
                    setState(() {
                      _commentList.add({
                        'user_code': user.id.toString(),
                        'comment': _content,
                        'time': Timestamp.fromDate(now),
                        'enable': true
                      });
                      _controller.clear();
                      _showBottomSection = true;
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
            return commentItem(
                context,
                commentList[index] as Map<String, dynamic>,
                commentUserList[index]);
          },
        ),
      ],
    );
  }

  Widget commentItem(BuildContext context, Map<String, dynamic> comment,TaxiScreenUserModel user) {
    DateTime writeTime = (comment['time'] as Timestamp).toDate();
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.profileImageUrl),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                user.userId == widget.writer.userId
                    ? Text(
                        "${user.nickname} (방장)",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : Text(user.nickname),
                Padding(
                  padding: EdgeInsets.only(
                      left: width * 0.02),
                  child: Text(
                    "${DateTime.now().difference(writeTime).inMinutes}분전",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            Text(comment['comment'])
          ],
        )
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: height * 0.05,
        color: Colors.grey.shade50,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "정원 4명중 ${_memberList.length + 1}명 참여중",
                  style: TextStyle(
                      fontSize: fontSize * 1.2,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "${widget.writer.gender}만 참여가능",
                  style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.grey),
                )
              ],
            ),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  bool isWriter = widget.writer.userId == currUser.id.toString();
                  if (isWriter) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미 합승중입니다')),
                    );
                    return;
                  }
                  if (_memberList.contains(currUser.id.toString())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미 합승중입니다')),
                    );
                    return;
                  }
                  bool sameGender = widget.writer.gender == currUser.gender;
                  if(! sameGender){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.writer.gender}만 참여 가능합니다')),
                    );
                    return;
                  }
                  try {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference collection =
                        firestore.collection(widget.collectionName);
                    QuerySnapshot querySnapshot = await collection
                        .where('createdTime', isEqualTo: widget.post.createdTime)
                        .get();
                    var doc = querySnapshot.docs.first;
                    var commentList = doc['memberList'] as List<dynamic>;
                    commentList.add(currUser.id.toString());
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
                    _memberList.add(currUser.id.toString());
                    _showMemberSection = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('합승 완료')),
                  );
                },
                child: widget.writer.userId == currUser.id.toString() ||
                        _memberList.contains(currUser.id.toString())
                    ? const Text("합승중")
                    : const Text("합승하기"))
          ],
        ),
      ),
    );
  }

  Row memberListItem(BuildContext context, String imageUrl, String name, String role, Widget buttonArea){
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        Text(
          name,
          style: TextStyle(
              fontSize: fontSize * 1.1,
              fontWeight: FontWeight.bold
          ),
        ),
        Text(
          " $role",
          style: const TextStyle(
              color: Colors.grey
          ),
        ),
        const Spacer(),
        buttonArea
      ],
    );
  }

  Future<Widget> _buildMemberListSection(BuildContext context) async {
    UserProvider currUser = Provider.of<UserProvider>(context, listen: false);
    List<String> memberIdList = _memberList.map((e) => e as String).toList();
    List<TaxiScreenUserModel> memberList = await TaxiScreenUserModel.getUserList(memberIdList);

    bool isWriter = widget.post.writerId == currUser.id.toString();
    List<Widget> listView = [];
    if(isWriter){
      listView.add(memberListItem(context, widget.writer.profileImageUrl, widget.writer.nickname, "방장", Container()));
      for(var e in memberList){
        listView.add(memberListItem(context, e.profileImageUrl, e.nickname, "참여자", kickOutButton(e.userId)));
      }
    } else{ // 참여자일 경우
      listView.add(memberListItem(context, widget.writer.profileImageUrl, widget.writer.nickname, "방장", wireButton()));
      for(var e in memberList){
        listView.add(memberListItem(context, e.profileImageUrl, e.nickname, "참여자", Container()));
      }
    }

    return DraggableScrollableSheet(
      minChildSize: 0.1,
      maxChildSize: 0.5,
      initialChildSize: 0.1,
      builder: (BuildContext context2, ScrollController controller){
        return Container(
          height: height * 0.5,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey,
              width: 1
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ]
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Stack(
              children: [
                Container(
                  height: height * 0.5,
                  padding: EdgeInsets.only(
                    top: height * 0.02
                  ),
                  child: ListView(
                    children: listView,
                  )
                ),
                Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 15,
                            width: 100,
                            margin: EdgeInsets.only(
                              top: width * 0.02
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: mainColor
                            ),
                          )
                        ]
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.05
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "참여자",
                            style: TextStyle(
                              fontSize: fontSize * 1.1,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
        );
      }
    );
  }

  ElevatedButton kickOutButton(String kickId){
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
          await collection
              .doc(doc.id)
              .update({'memberList': newMemberList});
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
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent
      ),
      child: const Text("추방하기"),
    );
  }
  //송금 버튼
  ElevatedButton wireButton(){
    return ElevatedButton(
      onPressed: () {
        try{
          launchURL(widget.writer.qrCodeUrl!);
        }catch(e){
          log.e(e);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('송금 실패')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: mainColor
      ),
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
      await collection
          .doc(doc.id)
          .update({'memberList': newMemberList});
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
