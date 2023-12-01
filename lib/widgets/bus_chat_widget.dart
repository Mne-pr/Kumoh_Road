import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BusChatWidget extends StatefulWidget {
  final VoidCallback onScrollToTop;
  const BusChatWidget({required this.onScrollToTop, super.key});

  @override
  State<BusChatWidget> createState() => _BusChatWidgetState();
}
class _BusChatWidgetState extends State<BusChatWidget> {
  final TextEditingController _commentController = TextEditingController();
  bool isNoChat = true;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(handleTxtChange);
  }

  void handleTxtChange() {
    setState(() {
      isNoChat = _commentController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {

    void submitComment() {
      // 댓글 서버에 보내야
      print('Submitted comment: ${_commentController.text}');
      _commentController.clear();
      try {FocusScope.of(context).unfocus();} catch(e) {}
    }

    return Container(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // 댓글
          Container(
            decoration: BoxDecoration( color: Colors.white,),
            height: MediaQuery.of(context).size.height / 2 - 60,
            child: RefreshIndicator(
              displacement: 100000, // 인디케이터 보이지 않도록
              onRefresh: () async {
                widget.onScrollToTop();
              },
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  // 첫째 줄
                  if (index == 0) {
                    return Container(
                      decoration: BoxDecoration( border: Border(top: BorderSide(width: 1.0, color: Colors.grey.shade200),), ),
                      child: Stack(
                        children: [
                          Container( alignment: Alignment.center, height: 22.0, child: Icon(Icons.arrow_drop_down,size: 20.0,), ),
                          ListTile(title: Text('Item ${index + 1}'))
                        ],
                      ),
                    );
                  }

                  // 나머지 줄
                  return Container(
                    decoration: BoxDecoration( border: Border( top: BorderSide(width: 1.0, color: Colors.grey.shade200),), ),
                    child: ListTile(title: Text('Item ${index + 1}')),
                  );
                },
              ),
            ),
          ),

          // 댓글 입력
          Container(
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black38,width: 1.0)) ),
            height: 60, //
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(filled: true, hintText: '댓글 입력...',fillColor: Color(0xff05d686).withOpacity(0.2)),
                      onSubmitted: (String text) { if (!isNoChat) submitComment(); },
                    ),
                  ),
                  SizedBox(width: 5,),
                  Material( // 버튼이 피드백 대처를 위한 공간 마련
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isNoChat ? null : submitComment,
                      borderRadius: BorderRadius.circular(24), // 클릭 피드백 동그라미
                      splashColor: Color(0xff05d686), // 물결 효과 색상 설정
                      child: Padding(
                        padding: EdgeInsets.all(9.0),
                        child: Icon(Icons.send, color: isNoChat ? Colors.grey : Colors.black),
                      ),
                    ),
                  ),
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
    _commentController.dispose();
    super.dispose();
  }
}
