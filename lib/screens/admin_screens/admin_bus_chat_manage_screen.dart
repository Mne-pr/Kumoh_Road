import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/admin_screens/admin_user_manage_detail_screen.dart';

import '../../models/report_bus_chat.dart';
import '../../widgets/admin_bottom_navigation_bar.dart';
import '../../widgets/report_count_widget.dart';
import 'admin_user_info_screen.dart';

class AdminBusChatManageScreen extends StatefulWidget {
  const AdminBusChatManageScreen({super.key});

  @override
  State<AdminBusChatManageScreen> createState() => _AdminBusChatManageScreenState();
}

class _AdminBusChatManageScreenState extends State<AdminBusChatManageScreen> {
  late List<ReportBusChatItem> curReportList  = [];
  late List<ReportBusChatItem> pastReportList = [];
  bool isCurrent = true;
  bool isLoading = true;

  // 현재 리포트만
  Future<void> fetchCurCommentReports() async {
    setState(() { isLoading = true;});

    final reportsSnapshot; // 버스 댓글 리포트 가져오기
    try {
      reportsSnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('entityType', isEqualTo: "comment")
          .where('isHandledByAdmin', isEqualTo: false)
          .where('reason', isNotEqualTo: "passedBus")
          .get();

      // 해당 채팅에 대한 분석 리스트(각 채팅 별 정보, 신고횟수, 신고자들 저장되어있음) 생성
      ReportBusChatAnalyzeList analyzedList = await ReportBusChatAnalyzeList.fromCollection(reportsSnapshot);

      // 저장
      setState(() { curReportList = analyzedList.list; });
    }
    catch(e) {
      print('get reports of bus_chat error : ${e}');
      setState(() { curReportList = [];});
    }
    setState(() { isLoading = false;});
  }

  // 과거 리포트만
  Future<void> fetchPastCommentReports() async {
    setState(() { isLoading = true;});
    final reportsSnapshot; // 버스 댓글 리포트 가져오기
    try {
      reportsSnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('entityType', isEqualTo: "comment")
          .where('isHandledByAdmin', isEqualTo: false)
          .where('reason', isEqualTo: "passedBus")
          .get();

      // 해당 채팅에 대한 분석 리스트(각 채팅 별 정보, 신고횟수, 신고자들 저장되어있음) 생성
      ReportBusChatAnalyzeList analyzedList = await ReportBusChatAnalyzeList.fromCollection(reportsSnapshot);

      // 저장
      setState(() { pastReportList = analyzedList.list; });
    }
    catch(e) {
      print('get reports of bus_chat error : ${e}');
      setState(() { pastReportList = [];});
    }
    setState(() { isLoading = false;});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {fetchCurCommentReports(); setState(() { isLoading = true;});});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((isCurrent) ? '버스 댓글 신고 관리 - 유효한 댓글' : '버스 댓글 신고 관리 - 만료된 댓글', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: (isLoading) ?
            Center(
              child: Center( child: CircularProgressIndicator(),),
            ) :
            ListView.builder(
              itemCount: (isCurrent) ? curReportList.length : pastReportList.length,
              itemBuilder: (context, index) {
                final commentReportedItem = (isCurrent) ? curReportList[index] : pastReportList[index];
                return buildCommentTile(commentReportedItem);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: Transform.scale(
                alignment: Alignment.bottomRight,
                scale: 1.4,
                child: CupertinoSwitch(
                  activeColor: Colors.grey,
                  trackColor: const Color(0xFF3F51B5),
                  value: !isCurrent,
                  onChanged: (value) {
                    setState(() {
                      isCurrent = !value;
                      isLoading = true; // 스위치를 토글할 때 로딩 상태를 true로 설정
                    });
                    if (value) {
                      fetchCurCommentReports();
                    } else {
                      fetchPastCommentReports();
                    }
                  },
                ),
              ),
            )
          ),
        ],
      ),
      bottomNavigationBar: const AdminCustomBottomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }

  Widget buildCommentTile(ReportBusChatItem comment) {

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
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminUserInfoScreen(userId: comment.userModel.userId), // 임시임
              ),
            );
          },
          child: CircleAvatar( backgroundImage: NetworkImage(comment.userModel.profileImageUrl),),
        ),
        title: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    comment.userModel.nickname,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  ReportCountWidget(comment.reportCounts), // 신고 횟수를 이름 바로 옆으로 이동
                ],
              ),
            ),
            Text(
              '${comment.userModel.mannerTemperature}°C',
              style: TextStyle(
                fontSize: 16,
                color: _getTemperatureColor(comment.userModel.mannerTemperature),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            _getTemperatureEmoji(comment.userModel.mannerTemperature),
          ],
        ),
        subtitle: Row(
          children: [
            Text('${comment.commentString}'),
            const Spacer(),
            _buildMannerBar(comment.userModel.mannerTemperature),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('기능 미구현입니다..'),duration: Duration(milliseconds: 700)),
          );
        },
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
