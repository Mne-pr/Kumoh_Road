import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/comment_model.dart';

import '../models/user_model.dart';

class BusChatWidget extends StatefulWidget {
  final Function(String) submitComment;
  final VoidCallback onScrollToTop;
  final List<Comment> comments;
  final List<UserModel> users;
  final bool isLoading;

  const BusChatWidget({
    required this.onScrollToTop,
    required this.submitComment,
    required this.isLoading,
    required this.comments,
    required this.users,
    super.key
  });

  @override
  State<BusChatWidget> createState() => _BusChatWidgetState();
}

class _BusChatWidgetState extends State<BusChatWidget> {
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

    if (widget.isLoading == true){ // 로딩 중
      return Container(
        padding:    EdgeInsets.all(0),
        decoration: BoxDecoration(
          color:     Colors.white,
          border:    Border(
            top:      BorderSide(width: 2.0, color: const Color(0xFF3F51B5).withOpacity(0.2),),
            bottom:   BorderSide(width: 0.5, color: const Color(0xFF3F51B5).withOpacity(0.2),),
        ),),

        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child:  Center( child: CircularProgressIndicator(),),
        ),),

      );
    }

    List<Comment> commentList = widget.comments;
    List<UserModel> userList  = widget.users;

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
              onRefresh:    () async {widget.onScrollToTop();},

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
                          ListTile (title: Text('${user.nickname} : ${comment.comment}')), // ui 수정해야
                  ],),);}

                  else { // 나머지 줄
                    return Container(
                      decoration: BoxDecoration( border: Border( top: BorderSide(width: 1.0, color: Colors.grey.shade200),), ),
                      child:      ListTile(title: Text('${user.nickname} : ${comment.comment}')), // ui 수정해야
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
                      decoration:  InputDecoration(filled: true, hintText: '댓글 입력',fillColor: const Color(0xFF3F51B5).withOpacity(0.1)),
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
