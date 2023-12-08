import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  final String   comment;
  final bool     enable;
  final DateTime createdTime;
  final String   writerId;
  String         targetDoc; // (버스채팅=> 버스코드)

  Comment({
    required this.comment,
    required this.enable,
    required this.createdTime,
    required this.writerId,
    this.targetDoc="",
  });

  factory Comment.fromJson(Map<String, dynamic> json, {String extraData=""}) {
    return Comment(
      enable: json['enable'],
      comment: json['comment'].toString(),
      createdTime: (json['createdTime'] as Timestamp).toDate(),
      writerId: json['writerId'].toString(),
      targetDoc: extraData,
    );
  }

}
class CommentList{
  final List<Comment> comments;
  CommentList({required this.comments});

  factory CommentList.fromDocument(DocumentSnapshot doc, {String extraData=""}) {
    List<Map<String,dynamic>> tempCommentList = [];
    List<Comment> commentList = [];

    if (doc.exists){
      final comments = doc.get('comments');
      for (var comment in comments) { 
        if (comment['enable'] == true) { // enable이 true인 유저만 추가
          tempCommentList.add(comment);
        }
      }

      try {
        commentList = tempCommentList.map((comment) => Comment.fromJson(comment,extraData: extraData)).toList();
        commentList.sort((comment1, comment2) => comment1.createdTime.compareTo(comment2.createdTime));
      } catch(e) { print('CommentList.fromDocument error: ${e.toString()}'); commentList=[];}

    } else {commentList = [];}

    return CommentList(comments: commentList);
  }
}


