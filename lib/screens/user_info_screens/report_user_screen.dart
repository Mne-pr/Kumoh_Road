import 'package:flutter/material.dart';
import 'detail_report_screen.dart'; // 실제 경로를 사용하세요.

class ReportUserScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;

  const ReportUserScreen({
    Key? key,
    required this.reportedUserId,
    required this.reportedUserName,
  }) : super(key: key);

  @override
  _ReportUserScreenState createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  void _navigateToDetailReportScreen(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailReportScreen(
          reportedUserId: widget.reportedUserId,
          reportedUserName: widget.reportedUserName,
          reportCategory: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신고하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '"${widget.reportedUserName}"\n사용자를 신고하는 이유를 선택해주세요',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('합승 시간 약속을 지키지 않음'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('합승 시간 약속을 지키지 않음'),
          ),
          ListTile(
            title: const Text('돈을 보내지 않음'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('돈을 보내지 않음'),
          ),
          ListTile(
            title: const Text('다른 사람의 아이디 사용'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('다른 사람의 아이디 사용'),
          ),
          ListTile(
            title: const Text('매너가 좋지 않음'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('매너가 좋지 않음'),
          ),
          ListTile(
            title: const Text('기타'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToDetailReportScreen('기타'),
          ),
        ],
      ),
    );
  }
}
