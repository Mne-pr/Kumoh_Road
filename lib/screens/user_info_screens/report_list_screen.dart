import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/user_providers.dart';
import '../../utilities/report_manager.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({Key? key}) : super(key: key);
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late ReportManager _reportManager;
  late Future<List<Map<String, dynamic>>> _reportList;

  @override
  void initState() {
    super.initState();
    final kakaoLoginProvider = Provider.of<UserProvider>(
        context, listen: false);

    if (kakaoLoginProvider.id != null) {
      _reportManager = ReportManager(kakaoLoginProvider);
      _reportList = _reportManager.fetchMyReports();
    } else {
      // 현재 사용자 ID가 없는 경우, 첫 번째 화면으로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

  @override
  bool get wantKeepAlive => true; // 이클립스 처리를 위해 상태 유지

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신고 내역', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('신고 내용이 없습니다.'));
          } else {
            return ListView(
              children: snapshot.data!
                  .map((report) => _buildReportCard(report))
                  .toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    String reportType = ''; // 신고 유형
    String reportTitle = report['category']; // 신고 상세 내용
    String reportDetail = report['reason']; // 신고 상세 내용
    String reportTime = ''; // 신고 시간

    if (report.containsKey('createdTime')) {
      Timestamp timestamp = report['createdTime'];
      DateTime reportedAt = timestamp.toDate();
      reportTime = DateFormat('yyyy-MM-dd HH:mm').format(reportedAt);
    }

    switch (report['entityType']) {
      case 'user':
        reportType = '사용자 신고';
        break;
      case 'post':
        reportType = '게시글 신고';
        break;
      case 'postComment':
        reportType = '게시글 댓글 신고';
        reportTitle = '댓글은 신고 유형 X';
        break;
      case 'comment':
        reportType = '댓글 신고';
        reportTitle = '댓글은 신고 유형 X';
        reportDetail = report['category'];
        break;
      default:
        reportType = '기타 신고';
        break;
    }

    return Card(
      child: ListTile(
        title: Text('$reportType : $reportTitle', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('신고 내용: $reportDetail\n신고 시간: $reportTime'),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              report['isHandledByAdmin'] ? Icons.check_circle : Icons.hourglass_empty,
              color: report['isHandledByAdmin'] ? Colors.green : Colors.blue,
            ),
            Text(
              report['isHandledByAdmin'] ? '처리됨' : '처리 중',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

