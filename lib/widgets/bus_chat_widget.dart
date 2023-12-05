import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumoh_road/models/comment_model.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:kumoh_road/utilities/report_manager.dart';

import '../models/user_model.dart';
import '../screens/user_info_screens/other_user_info_screen.dart';

// 버스 채팅 리스트
class BusChatListWidget extends StatefulWidget {
  final Function(String) submitComment;
  final VoidCallback onScrollToTop;
  final List<Comment>   comments;
  final List<UserModel> commentUsers;
  final bool isLoading;
  final UserProvider userProvider;

  const BusChatListWidget({
    required this.onScrollToTop,
    required this.submitComment,
    required this.isLoading,
    required this.comments,
    required this.commentUsers,
    required this.userProvider,
    super.key
  });

  @override
  State<BusChatListWidget> createState() => _BusChatListWidgetState();
}
class _BusChatListWidgetState extends State<BusChatListWidget> {
  final TextEditingController commentCon = TextEditingController();
  bool isNoChat = true;

  // 현재 채팅창이 공백인지 아닌지
  void handleTxtChange() {
    setState(() { isNoChat = commentCon.text.isEmpty;});
  }

  @override
  void initState() {
    super.initState();
    commentCon.addListener(handleTxtChange);
  }

  @override
  Widget build(BuildContext context) {

    List<Comment> commentList = widget.comments; 
    List<UserModel> userList  = widget.commentUsers;
    bool verified = widget.userProvider.isStudentVerified;

    // 댓글 추가 로직
    void submitComment() {
      widget.submitComment(commentCon.text);              // 부모에 댓글 전달
      commentCon.clear();                                 // 채팅창 클리어
      try {FocusScope.of(context).unfocus();} catch(e) {} // 키보드 비활성화
    }

    return Container(
      margin:     EdgeInsets.zero,
      decoration: BoxDecoration(
        border:    Border(
          top:      BorderSide(width: 2.0, color: const Color(0xFF3F51B5).withOpacity(0.2),),
          bottom:   BorderSide(width: 0.5, color: const Color(0xFF3F51B5).withOpacity(0.2),),
      ),),

      child: Column(
        children: [

          Container( // 댓글 출력 창
            decoration: BoxDecoration( color: Colors.white,),
            height:     MediaQuery.of(context).size.height / 2 - 60,

            child: RefreshIndicator(
              displacement: 100000, // 인디케이터 보이지 않도록
              onRefresh:    () async { widget.onScrollToTop();},

              child: (widget.isLoading) ?
                ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2 - 30,
                      child: Center( child: CircularProgressIndicator(),),
                    ),
                  ],
                ) : (commentList.isEmpty || userList.isEmpty) ?
                ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2 - 30,
                      child: Center(child: Text("채팅이 없습니다", style: TextStyle(fontSize: 20))),
                    ),
                  ],
                ) : ListView.builder(
                itemCount:   commentList.length,
                itemBuilder: (context, index) {

                  Comment comment = commentList[index]; // 댓글 유저 수 같아야 함.. 탈퇴한 유저? 아직 처리안함
                  UserModel user  = userList[index];

                  if (index == 0) { // 첫째 줄
                    return Container(
                      child: Stack(
                        children: [
                          Container( alignment: Alignment.center, height: 22.0, child: Icon(Icons.arrow_drop_down,size: 20.0,), ),
                          OneChatWidget( user: user, comment: comment, userProvider: widget.userProvider, ),
                        ],),);}

                  else { // 나머지 줄
                    return Container(
                      decoration: BoxDecoration( border: Border(
                          top: BorderSide(width: 1.0, color: Colors.grey.shade200),
                          bottom: (index == commentList.length-1) ? BorderSide(width: 1.0, color: Colors.grey.shade200) : BorderSide.none),
                      ), child:   OneChatWidget( user: user, comment: comment, userProvider: widget.userProvider, ),
                    );}
                },
              ),
            ),
          ),


          Container( // 댓글 입력 창
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(width: 1.0, color: const Color(0xFF3F51B5).withOpacity(0.2),),) ),
            height:     60,

            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),

              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller:  commentCon,
                      enabled: verified,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration:  InputDecoration(
                          filled: true,
                          hintText: verified ? '댓글 입력' : '댓글을 작성하려면 학생인증이 필요합니다',
                          hintStyle: verified
                              ? (isNoChat ? TextStyle(color: const Color(0xFF3F51B5)) : TextStyle(color: Color(0xFF3F51B5).withOpacity(0.1)))
                              : TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          fillColor: verified
                              ? (isNoChat ? const Color(0xFF3F51B5).withOpacity(0.1) : const Color(0xFF3F51B5).withOpacity(0.6))
                              : Color(0xFF3F51B5).withOpacity(0.1)
                      ),
                      onSubmitted: (String text) { if (!isNoChat) submitComment(); },
                  ),),

                  SizedBox(width: 5,),

                  Material( // 버튼이 피드백 대처를 위한 공간 마련
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:        isNoChat ? null : submitComment,
                      borderRadius: BorderRadius.circular(24), // 클릭 피드백 동그라미
                      splashColor:  Color(0xff05d686), // 물결 효과 색상 설정
                      child: Padding(
                        padding: EdgeInsets.all(9.0),
                        child:   Icon(Icons.send, color: isNoChat ? Colors.grey : const Color(0xFF3F51B5)),
                  ),),),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    commentCon.dispose();
    super.dispose();
  }
}


// 채팅 객체 하나
class OneChatWidget extends StatefulWidget {
  final UserModel user;
  final Comment comment;
  final UserProvider userProvider;

  const OneChatWidget({
    required UserModel this.user,
    required Comment this.comment,
    required UserProvider this.userProvider,
    super.key
  });

  @override
  State<OneChatWidget> createState() => _chatState();
}

class _chatState extends State<OneChatWidget> {
  final fire = FirebaseFirestore.instance;

  String _timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  // 댓글 등록
  Future<void> reportComment(ReportManager manager) async {
    await manager.reportComment(
      category: widget.comment.comment,   // 댓글 내용
      reportedUserId: widget.user.userId, // 신고한 유저 아이디 - 본인
      reason: widget.comment.targetDoc,   // 버스 코드 (버스정류장아이디-버스번호-버스경로)
      commentId: widget.comment.createdTime.toString(),     // 댓글 생성 시간 - 댓글 구별용
    );
  }

  // 댓글 삭제 - 미확인
  Future<void> deleteComment() async {
    final comment = widget.comment;
    final busChatDoc = fire.collection('bus_chat').doc(comment.targetDoc);
    
    try {
      DocumentSnapshot doc = await busChatDoc.get();
      if (doc.exists) {
        List<dynamic> items = List.from(doc['comments']);
        items.removeWhere((item) => (
            (item['createdTime'] as Timestamp) == comment.createdTime &&
            item['writerId'] as String == comment.writerId &&
            item['comment'] as String == comment.comment
        ));

        await busChatDoc.update({'comments': items});
      }
    } catch(e) { print('Error removing item: $e');}

  }

  @override
  Widget build(BuildContext context) {
    ReportManager reportManager = ReportManager(widget.userProvider);
    String userId = widget.user.userId;
    bool isOwner = userId == widget.userProvider.id.toString(); // 댓글작성자와 본인 비교위함

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          // 유저 프사
          GestureDetector(
            onTap: () {
              if (!isOwner){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OtherUserProfileScreen(userId: userId),
                  ),
                );
              }
            },
            child: CircleAvatar( backgroundImage: NetworkImage(widget.user.profileImageUrl),),
          ),
          SizedBox(width: 10,),
          // 유저 닉네임, 댓글
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text(widget.user.nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(_timeAgo(widget.comment.createdTime), style: const TextStyle(fontSize: 10, color: Colors.grey)), // 작성일 표시
                  ],
                ),
                SizedBox(height: 5,),
                Text(widget.comment.comment, style: TextStyle(fontSize: 17),),
              ],
            ),
          ),
          !isOwner ?
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0),),
            icon: Icon(Icons.more_vert, color: Color(0xFF3F51B5),),
            shadowColor: Color(0xFF3F51B5).withOpacity(0.3),
            color: Colors.white,
            elevation: 3.0,

            onSelected: (String value) async {
              if (value == 'report') {
                await reportComment(reportManager);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신고가 제출되었습니다'),duration: Duration(milliseconds: 700)),
                );
              }
            },

            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'report',
                  child: Text('신고', textAlign: TextAlign.end,),
                ),
              ];
            },
          ) :
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0),),
            icon: Icon(Icons.more_vert, color: Color(0xFF3F51B5),),
            shadowColor: Color(0xFF3F51B5).withOpacity(0.3),
            color: Colors.white,
            elevation: 3.0,

            onSelected: (String value) async {
              if (value == 'edit') {

              } else if (value == 'delete') {
                // 일단 커멘트에 모든 정보가 있으니깐?
                deleteComment();
              }
            },

            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('편집'),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('삭제'),
                ),
              ];
            },
          ),


        ],
      ),
    );
  }
}
