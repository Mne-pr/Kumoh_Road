import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../widgets/report_count_widget.dart';
import '../../widgets/user_info_section.dart';

class AdminUserManageDetailScreen extends StatefulWidget {
  final UserModel user;
  final Map<String, List<String>> reportDetails;

  AdminUserManageDetailScreen({
    Key? key,
    required this.user,
    required this.reportDetails,
  }) : super(key: key);

  @override
  _AdminUserManageDetailScreenState createState() => _AdminUserManageDetailScreenState();
}

class _AdminUserManageDetailScreenState extends State<AdminUserManageDetailScreen> {
  Future<void> suspendAccount(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isSuspended': true,
    });
  }

  Future<void> handleReports(String userId) async {
    var reportsSnapshot = await FirebaseFirestore.instance.collection('reports')
        .where('entityType', isEqualTo: 'user')
        .where('entityId', isEqualTo: userId)
        .get();

    for (var report in reportsSnapshot.docs) {
      await report.reference.update({'isHandledByAdmin': true});
    }

    Navigator.of(context).pop(); // 화면 닫기
  }

  Future<void> suspendUser(String userId) async {
    await suspendAccount(userId); // 계정을 정지시키는 함수 호출
    await handleReports(userId); // 신고 처리 로직
  }

  Future<void> ignoreReports(String userId) async {
    await handleReports(userId);
  }

  Widget _bottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton("무시", ignoreReports, Colors.grey, Icons.delete),
          const SizedBox(width: 10),
          _buildActionButton("계정 정지", suspendUser, const Color(0xFF3F51B5), Icons.block),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, Function onPressed, Color color, IconData icon) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () async {
          await onPressed(widget.user.userId);
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 신고 내용', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          UserInfoSection(
            nickname: widget.user.nickname,
            imageUrl: widget.user.profileImageUrl,
            age: widget.user.age,
            gender: widget.user.gender,
            mannerTemperature: widget.user.mannerTemperature,
          ),
          const Divider(),
          ...widget.reportDetails.entries.map((entry) {
            String category = entry.key;
            List<String> reports = entry.value;
            return ExpansionTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category),
                  const SizedBox(width: 8),
                  ReportCountWidget(reports.length),
                ],
              ),
              children: reports.map((report) {
                var parts = report.split('\n');
                String reason = '신고내용: ${parts[0]}';
                String date = '신고시간: ${parts[1]}';
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: reason,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '\n$date',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
      bottomNavigationBar: _bottomSection(),
    );
  }
}
