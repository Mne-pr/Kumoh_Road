import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  final String comment;
  final bool enable;
  final DateTime time;
  final String userCode;

  Comment({required this.comment, required this.enable, required this.time, required this.userCode});
}

class CommentApiRes{
  final List<Comment> comments;
  CommentApiRes({required this.comments});

  factory CommentApiRes.fromFireStore(List<Map<String,dynamic>> fireData) {
    List<Comment> commentList;

    try{
      commentList = fireData.map((map) {
        return Comment(
          comment: map['comment'],
          enable: map['enable'],
          time: (map['time'] as Timestamp).toDate(),
          userCode: map['user_code'],
        );
      }).toList();
    } catch(e) { print(e); commentList = [];}

    return CommentApiRes(comments: commentList);
  }
}