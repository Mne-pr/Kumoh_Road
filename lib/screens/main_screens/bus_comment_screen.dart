import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BusCommentsScreen extends StatefulWidget {
  final String busCode;

  const BusCommentsScreen({Key? key, required this.busCode}) : super(key: key);

  @override
  _BusCommentsScreenState createState() => _BusCommentsScreenState();
}

class _BusCommentsScreenState extends State<BusCommentsScreen> {
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    var commentsSnapshot = await FirebaseFirestore.instance
        .collection('bus_chat')
        .doc(widget.busCode)
        .collection('comments')
        .get();

    setState(() {
      comments = commentsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('댓글 관리 - 버스 ${widget.busCode}'),
      ),
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          var comment = comments[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(comment['profileImageUrl']),
            ),
            title: Text(comment['nickname']),
            subtitle: Text(comment['content']),
            trailing: Text(DateFormat('yyyy-MM-dd HH:mm').format(comment['timestamp'].toDate())),
            onTap: () {
              // 댓글 상세 정보 보기 또는 상호작용 로직 구현
            },
          );
        },
      ),
    );
  }
}