import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_providers.dart';
import '../../utilities/report_manager.dart';

class DetailReportScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;
  final String reportCategory;

  const DetailReportScreen({
    Key? key,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reportCategory,
  }) : super(key: key);

  @override
  _DetailReportScreenState createState() => _DetailReportScreenState();
}

class _DetailReportScreenState extends State<DetailReportScreen> {
  final TextEditingController _detailController = TextEditingController();
  late final ReportManager _reportManager;

  @override
  void initState() {
    super.initState();
    final kakaoLoginProvider = Provider.of<UserProvider>(context, listen: false);
    String? currentUserId = kakaoLoginProvider.id.toString();
    if (currentUserId != null) {
      _reportManager = ReportManager(currentUserId);
    } else {
      // 현재 사용자 ID가 없는 경우, 첫 번째 화면으로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
  }

  void _submitDetailedReport() {
    if (_detailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 내용을 입력해주세요.')),
      );
      return;
    }

    _reportManager.reportUser(
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
        elevation: 0,
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
