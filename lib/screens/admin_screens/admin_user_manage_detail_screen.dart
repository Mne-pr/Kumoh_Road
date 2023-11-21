import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../widgets/report_count_widget.dart';
import '../../widgets/user_info_section.dart';

class AdminUserManageDetailScreen extends StatelessWidget {
  final UserModel user;
  final Map<String, List<String>> reportDetails; // 신고 세부사항

  AdminUserManageDetailScreen({
    Key? key,
    required this.user,
    required this.reportDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 신고 내용', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          UserInfoSection(
            nickname: user.nickname,
            imageUrl: user.profileImageUrl,
            age: user.age,
            gender: user.gender,
            mannerTemperature: user.mannerTemperature,
          ),
          const Divider(),
          ...reportDetails.entries.map((entry) {
            String category = entry.key;
            List<String> reports = entry.value;
            return ExpansionTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category),
                  const SizedBox(width: 8),
                  ReportCountWidget(reports.length), // 신고 횟수 위젯 사용
                ],
              ),
              children: reports.map((report) => ListTile(title: Text(report))).toList(),
            );
          }).toList(),
        ],
      ),
    );
  }
}
