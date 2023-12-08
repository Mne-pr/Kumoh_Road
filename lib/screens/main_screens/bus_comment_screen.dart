import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_providers.dart';
import '../../widgets/bus_chat_widget.dart';

class BusCommentsScreen extends StatefulWidget {
  final String code;
  const BusCommentsScreen({Key? key, required this.code}) : super(key: key);

  @override
  _BusCommentsScreenState createState() => _BusCommentsScreenState();
}

class _BusCommentsScreenState extends State<BusCommentsScreen> {
  List<Comment> comments = [];
  List<UserModel> commentUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  Future<void> getComments() async {
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore fire = FirebaseFirestore.instance;
    final commentDoc = fire.collection('bus_chat').doc(widget.code);
    final userCollection = fire.collection('users');

    DocumentSnapshot commentData = await commentDoc.get();
    CommentList commentlist = CommentList.fromDocument(
        commentData, extraData: widget.code);

    List<UserModel> tempUsers = [];
    for (final comment in commentlist.comments) {
      try {
        final users = await userCollection.doc(comment.writerId).get();
        final user = UserModel.fromDocument(users);
        tempUsers.add(user);
      } catch (e) {
        print('get user data about comment error : ${e.toString()}');
      }
    }

    setState(() {
      comments = commentlist.comments;
      commentUsers = tempUsers;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context)
      ..startListeningToUserChanges();

    void submitComment(String comment) async {
      // 댓글 문서 가져오기
      final chatDoc = FirebaseFirestore.instance.collection('bus_chat').doc(
          widget.code);

      // 문서의 comments 필드에 추가
      await chatDoc.update({
        'comments': FieldValue.arrayUnion([{
          'comment': comment,
          'enable': true,
          'createdTime': Timestamp.now(),
          'writerId': userProvider.id.toString(),
        }
        ])
      });
      // 유저의 코멘트 수 증가
      await userProvider.updateUserInfo(
          commentCount: userProvider.commentCount + 1);
      // 댓글 다시 불러오기
      await getComments();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('댓글 정보', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                // 각 댓글을 표시하는 위젯
                Comment comment = comments[index];
                UserModel user = commentUsers[index];
                return OneChatWidget(user: user,
                  comment: comment,
                  userProvider: userProvider,
                  updateComment: getComments,);
              },
            ),
          ),
          _buildCommentInput(submitComment, userProvider)
        ],
      ),
    );
  }

  Widget _buildCommentInput(void Function(String) submitComment,
      UserProvider userProvider) {
    TextEditingController commentController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              enabled: userProvider.isStudentVerified,
              decoration: InputDecoration(
                hintText: userProvider.isStudentVerified
                    ? '버스 정보를 공유해주세요!'
                    : '댓글을 작성하려면 학생인증이 필요합니다',
                border: const OutlineInputBorder(),
                hintStyle: TextStyle(color: userProvider.isStudentVerified
                    ? Colors.black
                    : Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (userProvider.isStudentVerified && commentController.text
                  .trim()
                  .isNotEmpty) {
                submitComment(commentController.text);
                commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}