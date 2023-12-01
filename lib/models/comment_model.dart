import 'package:cloud_firestore/cloud_firestore.dart';

class Comment{
  final String comment;
  final bool enable;
  final DateTime time;
  final String who;

  Comment({required this.comment, required this.enable, required this.time, required this.who});
}

class CommentApiRes{
  final List<Comment> comments;
  CommentApiRes({required this.comments});

  factory CommentApiRes.fromFireStore(List<Map<String,dynamic>> fire) {
    List<Comment> commentList;

    try{
       commentList = fire.map((map) {
        return Comment(
          comment: map['comment'],
          enable: map['enable'],
          time: (map['time'] as Timestamp).toDate(),
          who: map['who'],
        );
      }).toList();
    } catch(e) { commentList = [];}


    return CommentApiRes(comments: commentList);
  }
}