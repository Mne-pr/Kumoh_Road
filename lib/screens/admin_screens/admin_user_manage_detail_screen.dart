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
  bool allReportsHandled = false;
  bool actionTaken = false; // 어떤 조치가 취해졌는지 확인하는 플래그

  Future<void> suspendUser(String userId) async {
    if (!actionTaken) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isSuspended': true,
      });

      var reportsSnapshot = await FirebaseFirestore.instance.collection('reports')
          .where('entityType', isEqualTo: 'user')
          .where('entityId', isEqualTo: userId)
          .get();

      for (var report in reportsSnapshot.docs) {
        await report.reference.update({'isHandledByAdmin': true});
      }

      setState(() {
        isSuspended = true;
        actionTaken = true; // 조치가 취해졌음을 표시
      });
    }
  }

  Future<void> handleAllReports() async {
    if (!actionTaken) {
      var reportsSnapshot = await FirebaseFirestore.instance.collection('reports')
          .where('entityType', isEqualTo: 'user')
          .where('entityId', isEqualTo: widget.user.userId)
          .get();

      for (var report in reportsSnapshot.docs) {
        await report.reference.update({'isHandledByAdmin': true});
      }

      setState(() {
        allReportsHandled = true;
        actionTaken = true; // 조치가 취해졌음을 표시
      });
    }
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
              children: reports.map((report) => ListTile(title: Text(report))).toList(),
            );
          }).toList(),
          if (!actionTaken) // 아직 조치가 취해지지 않았다면 두 개의 버튼을 보여줌
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      handleAllReports();
                    },
                    icon: const Icon(Icons.done_all, color: Colors.white),
                    label: const Text('사용자 신고 처리'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      suspendUser(widget.user.userId);
                    },
                    icon: const Icon(Icons.block, color: Colors.white),
                    label: const Text('사용자 계정 정지'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            )
          else // 조치가 취해졌다면 '조치 완료됨' 버튼을 보여줌
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('조치 완료됨'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
