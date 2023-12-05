import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../widgets/admin_bottom_navigation_bar.dart';
import '../../widgets/report_count_widget.dart';

class AdminBusChatManageScreen extends StatefulWidget {
  const AdminBusChatManageScreen({super.key});

  @override
  State<AdminBusChatManageScreen> createState() => _AdminBusChatManageScreenState();
}

class _AdminBusChatManageScreenState extends State<AdminBusChatManageScreen> {
  late List<ReportBusChatItem> reportList;


  Future<void> fetchAllCommentsAndReports() async {
    // 버스 댓글 리포트 가져오기
    var reportsSnapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('entityType', isEqualTo: "comment")
        .where('isHandledByAdmin', isEqualTo: false)
        .get();

    // 해당 채팅에 대한 분석 리스트(각 채팅 별 정보, 신고횟수, 신고자들 저장되어있음) 생성
    ReportBusChatAnalyzeList analyzedList = await ReportBusChatAnalyzeList.fromCollection(reportsSnapshot);

    // 저장
    setState(() { reportList = analyzedList.list; });
  }

  @override
  void initState() {
    super.initState();
    fetchAllCommentsAndReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('버스 댓글 신고 관리', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: reportList.length,
          itemBuilder: (context, index) {
            final commentReportedItem = reportList[index];
            return buildCommentTile(commentReportedItem);
          },
        ),
      ),
      bottomNavigationBar: const AdminCustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }

  Widget buildCommentTile(ReportBusChatItem comment) {

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(comment.targetId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 로딩 중일 때 표시할 위젯
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // 에러 발생시 표시할 위젯
        } else {
          final UserModel user = UserModel.fromDocument(snapshot.data!);
          return Container(
            margin:  const EdgeInsets.only(bottom: 3.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // Changes position of shadow
                ),
              ],
            ),
            child: ListTile(
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
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        ReportCountWidget(comment.reportCounts), // 신고 횟수를 이름 바로 옆으로 이동
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
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => AdminUserManageDetailScreen(
              //         user: user,
              //         reportDetails: reportDetails[user.userId] ?? {},
              //       ),
              //     ),
              //   ).then((_) {
              //     // 다시 이 화면으로 돌아왔을 때 사용자 목록과 신고 상태를 새로고침
              //     _fetchAllUsersAndReports();
              //   });
              // },
            ),
          );
        }
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
