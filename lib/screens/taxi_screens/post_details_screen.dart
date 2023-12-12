import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:kumoh_road/screens/main_screens/main_screen.dart';
import 'package:kumoh_road/screens/taxi_screens/post_report_screen.dart';
import 'package:kumoh_road/screens/taxi_screens/review_screen.dart';
import 'package:kumoh_road/screens/user_info_screens/other_user_info_screen.dart';
import 'package:kumoh_road/utilities/url_launcher_util.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../utilities/report_manager.dart';
import '../../widgets/manner_detail_widget.dart';
import 'package:uuid/uuid.dart';

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

class _PostDetailsScreenState extends State<PostDetailsScreen>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  String _content = "";
  bool _showMemberSection = false;
  bool _showReviewScreen = false;
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

    if (state == AppLifecycleState.resumed && _showReviewScreen) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return ReviewScreen(
            writerId: widget.writer.userId,
            writerName: widget.writer.nickname,
          );
        },
      ));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _commentList = widget.post.commentList;
    _memberList = widget.post.memberList;

    if (currUser == null) {
      currUser = Provider.of<UserProvider>(context);
      currUser!.startListeningToUserChanges();
      _reportManager = ReportManager(currUser!);
    }

    if (currUser!.id == null) {
      // 현재 사용자 ID가 없는 경우, 첫 번째 화면으로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
    _checkPostExistence();
  }

  Future<void> _checkPostExistence() async {
    try {
      String docId = await TaxiScreenPostModel.getDocId(
          collectionId: widget.collectionName,
          writerId: widget.writer.userId,
          createdTime: widget.post.createdTime
      );

      if (docId.isEmpty) {
        // 게시글이 없는 경우
        _showPostNotExistAlert();
      }
    } catch (e) {
      log.e("게시글 확인 중 오류 발생", error: e);
      _showPostNotExistAlert();
    }
  }

  void _showPostNotExistAlert() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("알림"),
            content: const Text("현재 삭제된 게시글입니다."),
            actions: <Widget>[
              TextButton(
                child: const Text("확인"),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          );
        },
      );
    });
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
                _showMemberSection = false;
              });
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopSection(),
                  const SizedBox(height: 4),
                  ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        if (currUser!.id.toString() != widget.writer.userId) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OtherUserProfileScreen(userId: widget.writer.userId),
                          ));
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(widget.writer.profileImageUrl),
                        radius: 28,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                widget.writer.nickname,
                                style: const TextStyle(
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${widget.writer.mannerTemperature}°C',
                          style: TextStyle(
                            fontSize: 16,
                            color: _getTemperatureColor(
                                widget.writer.mannerTemperature),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _getTemperatureEmoji(widget.writer.mannerTemperature),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text('${widget.writer.age}세 (${widget.writer.gender})'),
                        const Spacer(),
                        _buildMannerBar(widget.writer.mannerTemperature),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    // Padding 추가
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostContentSection(context),
                        const Divider(),
                        _buildReviewSection(context),
                        const Divider(),
                        FutureBuilder(
                          future: _buildCommentSection(context),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.hasError) {
                              log.e(snapshot.error);
                              log.e(snapshot.stackTrace);
                              return const Center(
                                child: Text("댓글 로딩 실패"),
                              );
                            } else if (snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                        SizedBox(
                          height: deviceHeight * 0.3,
                        ),
                      ],
                    ),
                  ),
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
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature >= 37.5) {
      return Colors.red;
    } else if (temperature >= 36.5) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Widget _getTemperatureEmoji(double temperature) {
    String emoji;
    if (temperature >= 37.5) {
      emoji = '🥵';
    } else if (temperature >= 36.5) {
      emoji = '😊';
    } else {
      emoji = '😨';
    }
    return Text(emoji);
  }

  Widget _buildMannerBar(double temperature) {
    return Container(
      width: 100, // 매너 막대 너비 고정
      height: 8, // 매너 막대 높이
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: temperature / 100,
          backgroundColor: Colors.grey[300],
          color: _getTemperatureColor(temperature),
          minHeight: 6,
        ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 왼쪽 아이콘들
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_outlined,
                        color: Colors.white,
                      ),
                    ),
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
                      ),
                    ),
                  ],
                ),
                // 게시글 신고 아이콘 (작성자가 아닐 경우에만 표시)
                currUser!.id.toString() != widget.writer.userId
                    ? PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'report') {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>
                              PostReportScreen(
                                reportedUserId: widget.writer.userId,
                                reportedUserName: widget.writer.nickname,
                                collectionName: widget.collectionName,
                                createdTime: widget.post.createdTime,
                              ),
                          )
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'report',
                      child: Text("게시글 신고하기"),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                )
                    : Container(), // 작성자일 경우 아무것도 표시하지 않음
              ],
            ),
          ),
        ),
      ],
    );
  }


  PopupMenuItem<String> reportMenuItem(String reportedUserId, String reportedUserName, String collectionName, DateTime createdTime) {
    return const PopupMenuItem<String>(
      value: 'report',
      child: Text("게시글 신고하기"),
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
    int minutesAgo =
        DateTime.now().difference(widget.post.createdTime).inMinutes;
    String timeText = minutesAgo > 0 ? "$minutesAgo분전" : "방금전";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.title,
            style: TextStyle(
              fontSize: deviceFontSize * 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4), // 제목과 시간 사이의 간격 조정
          Text(
            timeText,
            style:
                TextStyle(color: Colors.grey, fontSize: deviceFontSize * 0.9),
          ),
          const SizedBox(height: 8), // 시간과 내용 사이의 간격 조정
          Text(
            widget.post.content,
            style: TextStyle(fontSize: deviceFontSize),
          ),
          const SizedBox(height: 4), // 내용과 조회수 사이의 간격 조정
          Text(
            "조회 ${widget.post.viewCount}회",
            style:
                TextStyle(color: Colors.grey, fontSize: deviceFontSize * 0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    double defaultFontSize = deviceFontSize;

    List<Map<String, dynamic>> filteredMannerList = widget.writer.mannerList!
        .where((review) => review["votes"] > 0)
        .toList();
    List<Map<String, dynamic>> filteredUnmannerList = widget
        .writer.unmannerList!
        .where((review) => review["votes"] > 0)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "${widget.writer.nickname}님의 택시 합승 리뷰",
              style: TextStyle(
                  fontSize: defaultFontSize * 1.1, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right, size: 24),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => MannerDetailsWidget(
                  mannerList: filteredMannerList,
                  unmannerlyList: filteredUnmannerList,
                ),
              );
            },
          ),
          ...filteredMannerList
              .take(2)
              .map((review) => _buildReviewListItem(review, true))
              .toList(),
          ...filteredUnmannerList
              .take(2)
              .map((review) => _buildReviewListItem(review, false))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReviewListItem(Map<String, dynamic> review, bool isManner) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(review['content']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isManner ? Icons.thumb_up_alt : Icons.thumb_down_alt,
              color: isManner ? Colors.green : Colors.red, size: 20),
          const SizedBox(width: 4),
          Text('${review['votes']}'),
        ],
      ),
    );
  }

  Future<Widget> _buildCommentSection(BuildContext context) async {
    List<dynamic> commentList = _commentList;
    commentList = commentList.where((comment) => comment['enable'] == true).toList();
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
                fontSize: deviceFontSize * 1.1, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(currUser!.profileImageUrl!),
            ),
            const SizedBox(width: 10),
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
                if (!currUser!.isStudentVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('댓글 작성을 위해 학생 인증이 필요합니다')),
                  );
                  return;
                }
                if (_formKey.currentState!.validate()) {
                  DateTime now = DateTime.now();
                  _formKey.currentState!.save();
                  // DB에 댓글 정보 저장
                  try {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    String docId = await TaxiScreenPostModel.getDocId(
                        collectionId: widget.collectionName,
                        writerId: widget.writer.userId,
                        createdTime: widget.post.createdTime
                    );
                    var commentList = (await firestore.collection(widget.collectionName).doc(docId).get()).get('commentList') as List<dynamic>;
                    var uuid = const Uuid();
                    String commentId = uuid.v4(); // 고유 ID 생성
                    var newComment = {
                      'id': commentId,
                      'user_code': currUser!.id.toString(),
                      'comment': _content,
                      'time': now,
                      'enable': true
                    };
                    commentList.add(newComment);
                    await firestore.collection(widget.collectionName).doc(docId).update({'commentList': commentList});
                    int newPostCommentCnt = currUser!.postCommentCount + 1;
                    currUser!.updateUserInfo(postCommentCount: newPostCommentCnt);
                    FocusScope.of(context).unfocus();

                    setState(() {
                      _commentList.add({
                        'id': commentId,
                        'user_code': currUser!.id.toString(),
                        'comment': _content,
                        'time': Timestamp.fromDate(now),
                        'enable': true
                      });
                      _controller.clear();
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
          physics: const NeverScrollableScrollPhysics(),
          itemCount: commentList.length,
          itemBuilder: (context, index) {
            return commentItem(context, commentList[index] as Map<String, dynamic>, index, commentUserList[index]);
          },
        ),
      ],
    );
  }

  Widget commentItem(BuildContext context, Map<String, dynamic> comment,
      int commentIndex, TaxiScreenUserModel user) {
    DateTime writeTime = (comment['time'] as Timestamp).toDate();
    String timeText = DateTime.now().difference(writeTime).inMinutes == 0
        ? "방금 전"
        : "${DateTime.now().difference(writeTime).inMinutes}분 전";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (currUser!.id.toString() != user.userId) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OtherUserProfileScreen(userId: user.userId),
                ));
              }
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.profileImageUrl),
              radius: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.userId == widget.writer.userId
                            ? "${user.nickname} (방장)"
                            : user.nickname,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(timeText, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                InkWell(
                  child: Text(
                    comment['comment'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'delete') {
                _confirmDeletion(context, comment);
              } else if (value == 'report') {
                _reportComment(comment['id'], comment["user_code"], comment["comment"]);
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                if (user.userId == currUser!.id.toString())
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('삭제하기'),
                  ),
                if (user.userId != currUser!.id.toString())
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Text('신고하기'),
                  ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  void _reportComment(String commentId, String reportedUserId, String commentContent) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("댓글 신고"),
          content: const Text("이 댓글을 신고하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("신고"),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  String docId = await TaxiScreenPostModel.getDocId(
                      collectionId: widget.collectionName,
                      writerId: widget.writer.userId,
                      createdTime: widget.post.createdTime);
                  _reportManager.reportPostComment(
                      postCommentId:
                          "${widget.collectionName}:$docId:$commentId",
                      reason: commentContent,
                      category: "",
                      reportedUserId: reportedUserId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('신고 처리가 되었습니다')),
                  );
                } catch (e) {
                  // 오류 처리
                  log.e("신고 처리 중 오류 발생", error: e);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('신고 처리 실패')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletion(BuildContext context, Map<String, dynamic> comment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("댓글 삭제"),
          content: const Text("이 댓글을 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: const Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("삭제"),
              onPressed: () async {
                Navigator.of(context).pop();
                _deleteComment(comment);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComment(Map<String, dynamic> comment) async {
    try {
      String docId = await TaxiScreenPostModel.getDocId(
          collectionId: widget.collectionName,
          writerId: widget.writer.userId,
          createdTime: widget.post.createdTime);

      // Firestore에서 댓글 삭제
      FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(docId)
          .update({'commentList': FieldValue.arrayRemove([comment])})
          .then((_) {
        setState(() {
          _commentList.removeWhere((c) => c['id'] == comment['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 삭제되었습니다')),
        );
      });
    } catch (e) {
      log.e("댓글 삭제 중 오류 발생", error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 삭제 실패')),
      );
    }
  }

  Widget _buildBottomSection(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 55,
        color: Colors.white,
        child: Row(
          children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "정원 4명중 ${_memberList.length + 1}명 참여중",
              style: TextStyle(
                fontSize: deviceFontSize * 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${widget.writer.gender}만 참여가능",
              style: TextStyle(fontSize: deviceFontSize, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        Expanded(
          child: ElevatedButton(
              onPressed: () async {
                bool isWriter = widget.writer.userId == currUser!.id.toString();
                if (!currUser!.isStudentVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('합승 참여를 위해 학생 인증이 필요합니다')),
                  );
                  return;
                }
                if (isWriter) {
                  setState(() {
                    _showMemberSection = !_showMemberSection;
                  });
                  return;
                }
                if (_memberList.contains(currUser!.id.toString())) {
                  setState(() {
                    _showMemberSection = !_showMemberSection;
                  });
                  return;
                }
                if (_memberList.length >= 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('정원이 가득찼습니다.'),
                        duration: Duration(seconds: 1)),
                  );
                  return;
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
                  });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('합승 완료')),
                );
              },
            child: Text(
              _showMemberSection
                  ? "목록닫기"
                  : widget.writer.userId == currUser!.id.toString() ||
                  _memberList.contains(currUser!.id.toString())
                  ? "목록확인"
                  : "합승하기",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget memberListItem(BuildContext context, TaxiScreenUserModel user, String role, Widget buttonArea) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (currUser!.id.toString() != user.userId) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OtherUserProfileScreen(userId: user.userId),
                ));
              }
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.profileImageUrl),
              radius: 20, // 조정된 아바타 크기
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: TextStyle(
                      fontSize: deviceFontSize * 1.1, fontWeight: FontWeight.bold),
                ),
                Text(
                  role,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          buttonArea
        ],
      ),
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
        listView.add(memberListItem(context, e, "참여자", kickOutButton(e.userId)));
      }
    } else {
      listView.add(memberListItem(context, widget.writer, "방장", wireButton()));
      for (var e in memberList) {
        listView.add(memberListItem(context, e, "참여자", Container()));
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      builder: (BuildContext context2, ScrollController controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: ListView(
            controller: controller,
            children: listView,
          ),
        );
      },
    );
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

  ElevatedButton wireButton() {
    return ElevatedButton(
      onPressed: () {
        try {
          launchURL(widget.writer.qrCodeUrl!);
          setState(() {
            _showReviewScreen = true;
          });
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
