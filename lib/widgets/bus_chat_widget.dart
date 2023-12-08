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
  final VoidCallback updateComment;
  final List<Comment>   comments;
  final List<UserModel> commentUsers;
  final bool isLoading;
  final UserProvider userProvider;

  const BusChatListWidget({
    required this.onScrollToTop,
    required this.submitComment,
    required this.updateComment,
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
  bool isChatModifying = false;

  // 현재 채팅창이 공백인지 아닌지
  void onTxtChange() {
    if (commentCon.text.isEmpty || commentCon.text.trim().isEmpty || commentCon.text[0] == ' ') {
      setState(() { commentCon.text="";});
    }
    if (commentCon.text.length > 50) {
      setState(() { commentCon.text = commentCon.text.substring(0,50);});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('50자 이상 댓글을 달 수 없습니다'),duration: Duration(milliseconds: 250)),
      );
    }
    setState(() { isNoChat = commentCon.text.isEmpty;});
  }

  void modifyingChat() {
    setState(() { isChatModifying = true;});
  }

  @override
  void initState() {
    super.initState();
    commentCon.addListener(onTxtChange);
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

    // 댓글 읽어오기 로직
    void getComments() {
      setState(() { isChatModifying = false;});
      widget.updateComment();
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
            height:     MediaQuery.of(context).size.height / 2 - ((!isChatModifying) ? 62.5 : 0),

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
                      child: Center(child: Text("댓글이 없습니다", style: TextStyle(fontSize: 20))),
                    ),
                  ],
                ) : GestureDetector(
                onTap: () {setState(() { isChatModifying = false;}); FocusScope.of(context).unfocus();},
                child: ListView.builder(
                  itemCount:   commentList.length,
                  itemBuilder: (context, index) {

                    Comment comment = commentList[index]; // 댓글 유저 수 같아야 함.. 탈퇴한 유저? 아직 처리안함
                    UserModel user  = userList[index];

                    if (index == 0) { // 첫째 줄
                      return Container(
                        child: Stack(
                          children: [
                            Container( alignment: Alignment.center, height: 22.0, child: Icon(Icons.arrow_drop_down,size: 20.0,), ),
                            OneChatWidget( user: user, comment: comment, userProvider: widget.userProvider, updateComment: getComments, tellModifying: modifyingChat),
                          ],),);}

                    else { // 나머지 줄
                      return Container(
                        decoration: BoxDecoration( border: Border(
                            top: BorderSide(width: 1.0, color: Colors.grey.shade200),
                            bottom: (index == commentList.length-1) ? BorderSide(width: 1.0, color: Colors.grey.shade200) : BorderSide.none),
                        ), child:   OneChatWidget( user: user, comment: comment, userProvider: widget.userProvider, updateComment: getComments, tellModifying: modifyingChat),
                      );}
                  },
                ),
              ),
            ),
          ),

          (isChatModifying) ? SizedBox(width: 0,) :
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
                      decoration:  InputDecoration(
                        filled: true,
                        hintText: verified ? '버스 정보를 공유해주세요!' : '댓글을 작성하려면 학생인증이 필요합니다',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        hintStyle: verified
                            ? (isNoChat ? TextStyle(color: Colors.grey) : TextStyle(color: Colors.black))
                            : TextStyle(color: Colors.grey),
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
    commentCon.removeListener(onTxtChange);
    commentCon.dispose();
    super.dispose();
  }
}


// 채팅 객체 하나
class OneChatWidget extends StatefulWidget {
  final UserModel user;
  final Comment comment;
  final UserProvider userProvider;
  final VoidCallback updateComment;
  final VoidCallback? tellModifying;

  const OneChatWidget({
    required UserModel this.user,
    required Comment this.comment,
    required UserProvider this.userProvider,
    required VoidCallback this.updateComment,
    this.tellModifying,
    super.key
  });

  @override
  State<OneChatWidget> createState() => _chatState();
}
class _chatState extends State<OneChatWidget> {
  final TextEditingController commentCon = TextEditingController();
  final fire = FirebaseFirestore.instance;
  final FocusNode focusNode = FocusNode();
  late ReportManager reportManager;
  bool modifying = false;
  bool isNoChat = false;
  late String userId;
  bool isOwner = false;

  void onTxtChange() {
    if (commentCon.text.isEmpty || commentCon.text.trim().isEmpty || commentCon.text[0] == ' ') {
      setState(() { commentCon.text="";});
    }
    if (commentCon.text.length > 50) {
      setState(() { commentCon.text = commentCon.text.substring(0,50);});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('50자 이상 댓글을 달 수 없습니다'),duration: Duration(milliseconds: 250)),
      );
    }
    setState(() { isNoChat = commentCon.text.isEmpty;});
  }

  void onFocusChange() {
    if (!focusNode.hasFocus) {
      commentCon.text = widget.comment.comment;
      setState(() { modifying = false;});
    }
  }

  // 작성된 시간 측정
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

  // 댓글 신고
  Future<void> reportComment(ReportManager manager) async {
    await manager.reportComment(
      category: widget.comment.comment,   // 댓글 내용
      reportedUserId: widget.user.userId, // 신고한 유저 아이디 - 본인
      reason: widget.comment.targetDoc,   // 버스 코드 (버스정류장아이디-버스번호-버스경로)
      commentId: widget.comment.createdTime.toString(),     // 댓글 생성 시간 - 댓글 구별용
    );
  }

  // 댓글 삭제
  Future<void> deleteComment() async {
    // 댓글, 리포트 처리 방식 다르게 처리하는 이유
    // 댓글은 문서의 리스트 안에, 리포트는 문서 자체로 저장되어 있기 때문
    final comment = widget.comment;
    final busChatDoc = fire.collection('bus_chat').doc(comment.targetDoc);

    try {
      DocumentSnapshot doc = await busChatDoc.get();
      if (doc.exists) {
        List<dynamic> items = List.from(doc['comments']); // 당연히 하나 있겠지

        // 지우기 전에 reports에 해당 댓글 있는지 찾아봐
        QuerySnapshot targetInReport = await fire.collection('reports')
            .where('category',isEqualTo: comment.comment)
            .where('entityId',isEqualTo: comment.createdTime.toString())
            .where('reportedUserId',isEqualTo:comment.writerId)
            .get();

        // reports에 신고가 들어온 댓글이었다면 관련 리포트 지워버려
        if (targetInReport.docs.isNotEmpty) {
          for (DocumentSnapshot reportDoc in targetInReport.docs) {
            await fire.collection('reports').doc(reportDoc.id).delete();
          }
        }

        // 마지막으로 댓글 지워
        items.removeWhere((item) => (
            (item['createdTime'] as Timestamp).toDate() == comment.createdTime &&
                item['writerId'] as String == comment.writerId &&
                item['comment'] as String == comment.comment
        ));

        // 지운 댓글 반영해
        await busChatDoc.update({'comments': items});
      }
    } catch(e) { print('Error removing item: $e');}
    
    // 마무리
    widget.updateComment();

  }

  // 댓글 수정
  Future<void> updateComment() async {
    final text = commentCon.text;
    final comment = widget.comment;
    final busChatDoc = fire.collection('bus_chat').doc(comment.targetDoc);

    try {
      DocumentSnapshot doc = await busChatDoc.get();
      if (doc.exists) {
        List<dynamic> items = List.from(doc['comments']);// 당연히 하나 있겠지

        // 지우기 전에 reports에 해당 댓글 있는지 찾아봐
        QuerySnapshot targetInReport = await fire.collection('reports')
            .where('category',isEqualTo: comment.comment)
            .where('entityId',isEqualTo: comment.createdTime.toString())
            .where('reportedUserId',isEqualTo:comment.writerId)
            .get();
        
        // 있으면 바로 반영하기 - category만 수정하면 되겠는데
        if (targetInReport.docs.isNotEmpty) {
          for (DocumentSnapshot reportDoc in targetInReport.docs) {
            await fire.collection('reports').doc(reportDoc.id).update({'category': text});
          }
        }
        
        // 해당 댓글의 정보 수정함
        for (var item in items) {
          if ((item['createdTime'] as Timestamp).toDate() == comment.createdTime &&
              item['writerId'] as String == comment.writerId &&
              item['comment'] as String == comment.comment) {
            item['comment'] = text;
            break;
          }
        }
        
        // 수정한 댓글 반영함
        await busChatDoc.update({'comments': items});
      }
    } catch(e) { print('Error removing item: $e');}
    
    // 마무리 
    widget.updateComment();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('수정 완료!'),duration: Duration(milliseconds: 700)),
    );
  }

  @override
  void dispose(){
    commentCon.removeListener(onTxtChange);
    focusNode.removeListener(onFocusChange);
    commentCon.dispose(); focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    commentCon.text = widget.comment.comment;
    commentCon.selection = TextSelection.collapsed(offset: commentCon.text.length);
    reportManager = ReportManager(widget.userProvider);
    userId = widget.user.userId;
    isOwner = userId == widget.userProvider.id.toString();
    commentCon.addListener(onTxtChange);
    focusNode.addListener(onFocusChange);
  }

  @override
  Widget build(BuildContext context) {

    if (modifying){
      Future.delayed(Duration(milliseconds: 100), () {
        focusNode.requestFocus();
      });
    }

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
                    builder: (context) => OtherUserProfileScreen(userId: userId),
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
                (!modifying) ?
                Text(widget.comment.comment, style: TextStyle(fontSize: 17),) :
                SizedBox(
                  height: 60,
                  child: TextField(
                    focusNode: focusNode,
                    controller:  commentCon,
                    decoration:  InputDecoration(
                      filled: true,
                      hintText: '수정할 댓글 입력',
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      hintStyle: isNoChat ? TextStyle(color: Colors.black) : TextStyle(color: Colors.grey),
                    ),
                    onSubmitted: (String text) {
                      FocusScope.of(context).unfocus();
                      setState(() { modifying = false;});
                      if (!isNoChat) {updateComment();}
                    },
                  ),
                ),

              ],
            ),
          ),
          (modifying) ?
          Material( // 버튼이 피드백 대처를 위한 공간 마련
            color: Colors.transparent,
            child: InkWell(
              onTap: () { if(!isNoChat) updateComment();},
              borderRadius: BorderRadius.circular(24), // 클릭 피드백 동그라미
              splashColor:  Color(0xff05d686), // 물결 효과 색상 설정
              child: Padding(
                padding: EdgeInsets.all(9.0),
                child:   Icon(Icons.send, color: isNoChat ? Colors.grey : const Color(0xFF3F51B5)),
          ),),):
          (isOwner ?
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0),),
            icon: Icon(Icons.more_vert, color: Color(0xFF3F51B5),),
            shadowColor: Color(0xFF3F51B5).withOpacity(0.3),
            color: Colors.white,
            elevation: 3.0,

            onSelected: (String value) async {
              if (value == 'edit') {
                setState(() {
                  if (widget.tellModifying != null) { widget.tellModifying!();}
                  modifying = true;
                });
              }
              else if (value == 'delete') {
                // 일단 커멘트에 모든 정보가 있으니깐?
                deleteComment();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('삭제 완료!'),duration: Duration(milliseconds: 700)),
                );
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
          ) :
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
          )
          ),


        ],
      ),
    );
  }
}
