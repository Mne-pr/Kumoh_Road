import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/admin_screens/admin_user_info_screen.dart';

import '../../models/report_bus_chat.dart';
import '../../widgets/admin_bottom_navigation_bar.dart';
import '../../widgets/report_count_widget.dart';

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
  final reports = FirebaseFirestore.instance.collection('reports');
  final busChat = FirebaseFirestore.instance.collection('bus_chat');

  // 현재 리포트만 겟
  Future<void> fetchCurCommentReports() async {
    setState(() { isLoading = true;});

    final reportsSnapshot; // 버스 댓글 리포트 가져오기
    try {
      reportsSnapshot = await reports
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

  // 과거 리포트만 겟
  Future<void> fetchPastCommentReports() async {
    setState(() { isLoading = true;});
    final reportsSnapshot; // 버스 댓글 리포트 가져오기
    try {
      reportsSnapshot = await reports
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


  Future<void> setHandleTrue(ReportBusChatItem comment) async {
    // 처리를 true로(report, cur|pass 공통)
    try {
      QuerySnapshot targets = await reports.where('entityType', isEqualTo: 'comment')
          .where('entityId',isEqualTo: comment.writtenAt)
          .where('reason', isEqualTo: comment.chatId)
          .get();

      for (var target in targets.docs) {
        await target.reference.update({'isHandledByAdmin': true});
      }
    } catch(e) {
      print('setHandleTrue error : $e');
    }

  }

  Future<void> acceptReport(ReportBusChatItem comment) async {
    // 해당 글에 블라인드 처리(bus_chat, cur 댓글에 한해서!)
    try {
      if (isCurrent) {
        DocumentSnapshot chatDoc = await busChat.doc(comment.chatId).get();
        List<dynamic> commentsDynamic = chatDoc.get('comments');
        List<Map<String, dynamic>> comments = commentsDynamic.map((e) => e as Map<String, dynamic>).toList();

        for (var com in comments) {
          if (com['comment'] == comment.commentString
              && (com['createdTime'] as Timestamp).toDate().toString() == comment.writtenAt
              && com['writerId'] == comment.targetId) {
            com['enable'] = false;
          }
        }
        await busChat.doc(comment.chatId).update({'comments': comments});
      }
    } catch(e) {
      print('acceptReport error: $e');
    }

    // 처리완료
    await setHandleTrue(comment);
  }

  Future<void> rejectReport(ReportBusChatItem comment) async {
    // 처리완료
    await setHandleTrue(comment);
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
                if ((isCurrent && index==curReportList.length-1) || (!isCurrent && index==pastReportList.length-1)) {
                  return Column(
                    children: [
                      buildCommentTile(commentReportedItem, index),
                      SizedBox(height: 80,),
                    ],
                  );
                }
                return buildCommentTile(commentReportedItem, index);
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

  Widget buildCommentTile(ReportBusChatItem comment, int index) {

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

      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Dismissible(
          key: Key('${comment.chatId}-${comment.writtenAt}'),
          background: Container(
            color: Colors.grey,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child:Icon(Icons.do_not_disturb_alt_outlined, color: Colors.white),// Text('무시'),
          ),
          secondaryBackground: Container(
            color: const Color(0xFF3F51B5),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.remove_circle_outline, color: Colors.white),
          ),
          onDismissed: (direction) async {// 두 가지 경우를 다 생각해봐야 함
            if (direction == DismissDirection.endToStart) { // 왼쪽으로 - 블라인드처리
              await acceptReport(comment);
            } else {                                        // 오른쪽으로 - 무시
              await rejectReport(comment);
            }

            setState(() {
              // 뭔지에 따라 어느 리스트에서 삭제할지 결정해야
              if (isCurrent) { curReportList.removeAt(index) ;}
              else           { pastReportList.removeAt(index);}
            });
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${comment.commentString}',
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5.0), // 원하는 마진 값 설정
                        child: _buildMannerBar(comment.userModel.mannerTemperature),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {},
            ),
          ),
        ),
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
