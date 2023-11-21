import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kakao_login_providers.dart';
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
    final kakaoLoginProvider = Provider.of<KakaoLoginProvider>(context, listen: false);
    String? currentUserId = kakaoLoginProvider.getCurrentUserId();

    if (currentUserId != null) {
      _reportManager = ReportManager(currentUserId);
      _reportList = _reportManager.fetchMyReports();
    } else {
      // 현재 사용자 ID가 없는 경우, 첫 번째 화면으로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신고 내역', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
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
    IconData icon = Icons.report_problem; // 기본 아이콘
    String reportTitle = '신고 내용'; // 기본 신고 제목
    String reportDetail = report['reason']; // 신고 상세 내용

    // 신고 내용 파싱: '제목: 상세 내용'
    if (report['reason'].contains(':')) {
      var parts = report['reason'].split(':');
      reportTitle = parts[0].trim();
      reportDetail = parts.sublist(1).join(':').trim();
    }

    switch (report['entityType']) {
      case 'user':
        icon = Icons.person_outline;
        break;
      case 'post':
        icon = Icons.article;
        break;
      case 'comment':
        icon = Icons.comment;
        break;
    }

    return Card(
      child: ListTile(
        leading: Icon(icon, size: 38), // 아이콘 크기 조정
        title: Text(reportTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(reportDetail),
        trailing: Icon(
          report['isHandledByAdmin'] ? Icons.check_circle : Icons
              .hourglass_empty,
          color: report['isHandledByAdmin'] ? Colors.green : Colors.blue,
        ),
      ),
    );
  }
}
