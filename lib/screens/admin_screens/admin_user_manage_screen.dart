import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumoh_road/models/user_model.dart';
import '../../widgets/admin_bottom_navigation_bar.dart';
import '../../widgets/report_count_widget.dart';
import 'admin_user_manage_detail_screen.dart';

class AdminUserManageScreen extends StatefulWidget {
  const AdminUserManageScreen({Key? key}) : super(key: key);

  @override
  _AdminUserManageScreenState createState() => _AdminUserManageScreenState();
}

class _AdminUserManageScreenState extends State<AdminUserManageScreen> {
  List<UserModel> users = [];
  Map<String, int> userReportCounts = {};
  Map<String, Map<String, List<String>>> reportDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchAllUsersAndReports();
  }

  Future<void> _fetchAllUsersAndReports() async {
    var reportsSnapshot = await FirebaseFirestore.instance.collection('reports')
        .where('entityType', isEqualTo: 'user')
        .where('isHandledByAdmin', isEqualTo: false)
        .get();

    Map<String, int> reportCounts = {};
    Map<String, Map<String, List<String>>> reportDetails = {}; // 수정된 구조

    for (var report in reportsSnapshot.docs) {
      String userId = report['entityId'];
      String category = report['category'];
      Timestamp timestamp = report['timestamp'];
      DateTime reportedAt = timestamp.toDate();
      String content = "${report['reason']}\n${DateFormat('yyyy-MM-dd HH:mm').format(reportedAt)}";

      reportCounts[userId] = (reportCounts[userId] ?? 0) + 1;

      if (!reportDetails.containsKey(userId)) {
        reportDetails[userId] = {};
      }
      if (!reportDetails[userId]!.containsKey(category)) {
        reportDetails[userId]![category] = [];
      }
      reportDetails[userId]![category]!.add(content);
    }

    List<UserModel> fetchedUsers = [];
    for (var userDoc in (await FirebaseFirestore.instance.collection('users').get()).docs) {
      UserModel user = UserModel.fromDocument(userDoc);
      if (user.userId != '0' && reportCounts.containsKey(user.userId)) {
        fetchedUsers.add(user);
      }
    }

    setState(() {
      users = fetchedUsers;
      userReportCounts = reportCounts;
      this.reportDetails = reportDetails;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('사용자 신고 관리', style: TextStyle(color: Colors.black)),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserTile(user);
          },
        ),
      ),
      bottomNavigationBar: const AdminCustomBottomNavigationBar(
        selectedIndex: 3,
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    int reportsCount = userReportCounts[user.userId] ?? 0;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profileImageUrl),
        radius: 28, // 아바타 크기 증가
      ),
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  user.nickname,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                ReportCountWidget(reportsCount), // 신고 횟수를 이름 바로 옆으로 이동
              ],
            ),
          ),
          Text(
            '${user.mannerTemperature}°C',
            style: TextStyle(
              fontSize: 16,
              color: _getTemperatureColor(user.mannerTemperature),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          _getTemperatureEmoji(user.mannerTemperature),
        ],
      ),
      subtitle: Row(
        children: [
          Text('${user.age}세 (${user.gender})'),
          const Spacer(),
          _buildMannerBar(user.mannerTemperature),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminUserManageDetailScreen(
              user: user,
              reportDetails: reportDetails[user.userId] ?? {},
            ),
          ),
        ).then((_) {
          // 다시 이 화면으로 돌아왔을 때 사용자 목록과 신고 상태를 새로고침
          _fetchAllUsersAndReports();
        });
      },
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature >= 37.5) {
      return Colors.red;
    } else if (temperature >= 36.5) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Widget _getTemperatureEmoji(double temperature) {
    String emoji;
    if (temperature >= 37.5) {
      emoji = '🥵';
    } else if (temperature >= 36.5) {
      emoji = '😊';
    } else {
      emoji = '😨';
    }
    return Text(emoji);
  }

  Widget _buildMannerBar(double temperature) {
    return Container(
      width: 100, // 매너 막대 너비 고정
      height: 8, // 매너 막대 높이
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: temperature / 100,
          backgroundColor: Colors.grey[300],
          color: _getTemperatureColor(temperature),
          minHeight: 6,
        ),
      ),
    );
  }
}
