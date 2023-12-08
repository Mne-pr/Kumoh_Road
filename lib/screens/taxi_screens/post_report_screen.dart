import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/taxi_screens/post_report_detail_screen.dart';
import 'package:logger/logger.dart';

Logger log = Logger(printer: PrettyPrinter());

class PostReportScreen extends StatefulWidget {
  final String collectionName; // 어떤 컬렉션인가
  final String reportedUserId; // 누가 작성한 글인가(특정 게시글 판별조건 1)
  final String reportedUserName;
  final DateTime createdTime; // 몇시에 작성된 글인가(특정 게시글 판별조건 2)

  const PostReportScreen({
    Key? key,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.collectionName,
    required this.createdTime,
  }) : super(key: key);

  @override
  State<PostReportScreen> createState() => _PostReportScreenState();
}

class _PostReportScreenState extends State<PostReportScreen> {
  void _navigateToDetailReportScreen(String category) async {
    // 신고당한 그 1개 게시글 문서의 id를 읽기
    String postId = '';
    try {
      // 신고당한 게시글의 문서 id를 얻기
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference collection =
      firestore.collection(widget.collectionName);
      QuerySnapshot querySnapshot = await collection
          .where('writerId', isEqualTo: widget.reportedUserId)
          .where('createdTime', isEqualTo: widget.createdTime)
          .get();
      var doc = querySnapshot.docs.first;
      postId = doc.id;
    } on Exception catch (e) {
      log.e("신고당한 게시글 문서 id 불러오기 실패함", error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 내용 페이지 로딩 실패')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PostReportDetailScreen(
            postId: "${widget.collectionName}-$postId",
            reportedUserId: widget.reportedUserId,
            reportedUserName: widget.reportedUserName,
            reportCategory: category,
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 신고하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '신고하는 이유를 선택해주세요',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('스팸 홍보/도배글입니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('스팸 홍보/도배글입니다'),
          ),
          ListTile(
            title: const Text('음란물입니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('음란물입니다'),
          ),
          ListTile(
            title: const Text('불법 정보를 포함하고 있습니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('불법 정보를 포함하고 있습니다'),
          ),
          ListTile(
            title: const Text('불쾌한 표현이 있습니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('불쾌한 표현이 있습니다'),
          ),
        ],
      ),
    );
  }
}
