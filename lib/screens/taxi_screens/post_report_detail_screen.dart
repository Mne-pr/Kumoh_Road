import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_providers.dart';
import '../../utilities/report_manager.dart';

class PostReportDetailScreen extends StatefulWidget {
  final String postId;
  final String reportedUserId;
  final String reportedUserName;
  final String reportCategory;

  const PostReportDetailScreen({
    Key? key,
    required this.postId,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reportCategory,
  }) : super(key: key);

  @override
  State<PostReportDetailScreen> createState() => _PostReportDetailScreenState();
}

class _PostReportDetailScreenState extends State<PostReportDetailScreen> {
  final TextEditingController _detailController = TextEditingController();
  late final ReportManager _reportManager;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final kakaoLoginProvider = Provider.of<UserProvider>(context);
    kakaoLoginProvider.startListeningToUserChanges();
    if (kakaoLoginProvider.id != null) {
      _reportManager = ReportManager(kakaoLoginProvider);
    } else {
      // 현재 사용자 ID가 없는 경우, 첫 번째 화면으로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

  void _submitDetailedReport() async {
    if (_detailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 내용을 입력해주세요.')),
      );
      return;
    }

    _reportManager.reportPost(
      postId: widget.postId,
      reportedUserId: widget.reportedUserId,
      category : widget.reportCategory,
      reason: _detailController.text,
    );

    Navigator.pop(context);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('신고가 제출되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신고하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '"${widget.reportCategory}"\n사유로 신고하는 이유를 입력해주세요',
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Padding( // TextField를 Padding으로 감쌌습니다.
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _detailController,
                decoration: const InputDecoration(
                  labelText: '신고 내용을 작성해주세요.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ),
            Padding( // ElevatedButton를 Padding으로 감쌌습니다.
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ElevatedButton(
                onPressed: _submitDetailedReport,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('신고 제출'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }
}
