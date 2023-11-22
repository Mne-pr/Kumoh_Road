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
  bool isSuspended = false;

  Future<void> suspendUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isSuspended': true,
    });
    setState(() {
      isSuspended = true;
    });
  }

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
              children: reports.map((report) => ListTile(title: Text(report))).toList(),
            );
          }).toList(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: isSuspended ? null : () => suspendUser(widget.user.userId),
              icon: const Icon(Icons.block, color: Colors.white),
              label: Text(isSuspended ? '사용자 계정 정지됨' : '사용자 계정 정지'),
              style: ElevatedButton.styleFrom(backgroundColor: isSuspended ? Colors.grey : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
