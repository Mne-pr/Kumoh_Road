import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/comment_model.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:kumoh_road/utilities/report_manager.dart';

import '../models/user_model.dart';

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

  @override
  Widget build(BuildContext context) {
    ReportManager reportManager = ReportManager(widget.userProvider);

    Future<void> reportComment() async {
      await reportManager.reportComment(
        category: widget.comment.comment,
        reportedUserId: widget.user.userId,
        reason: "지원하지 않음",
        commentId: widget.comment.code,
      );
    }


    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          // 유저 프사
          CircleAvatar( backgroundImage: NetworkImage(widget.user.profileImageUrl),),
          SizedBox(width: 10,),
          // 유저 닉네임, 댓글
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.user.nickname, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                SizedBox(height: 5,),
                Text(widget.comment.comment, style: TextStyle(fontSize: 17),),
              ],
            ),
          ),
          // 팝업버튼 - 신고, 수정, 삭제(수정삭제는 예정 없음)
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0),),
            icon: Icon(Icons.more_vert, color: Color(0xFF3F51B5),),
            shadowColor: Color(0xFF3F51B5).withOpacity(0.3),
            color: Colors.white,
            elevation: 3.0,

            onSelected: (String value) {
              if (value == 'report') { reportComment(); }
            },

            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
              //   PopupMenuItem<String>(
              //     enabled: false,
              //     value: 'edit',
              //     child: Text('편집'),
              //   ),
              //   PopupMenuItem<String>(
              //     value: 'delete',
              //     child: Text('삭제'),
              //   ),
                // 여기에 더 많은 메뉴 항목을 추가할 수 있습니다.
                PopupMenuItem<String>(
                  value: 'report',
                  child: Text('신고', textAlign: TextAlign.end,),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
