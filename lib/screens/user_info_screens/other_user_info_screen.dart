import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/user_info_screens/report_user_screen.dart';
import '../../models/user_model.dart';
import '../../widgets/manner_detail_widget.dart';
import '../../widgets/user_info_section.dart';
import 'other_badge_screen.dart';
import 'other_user_manner_screen.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _OtherUserProfileScreenState createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  UserModel? otherUser; // UserModel은 사용자 데이터를 저장하는 모델 클래스입니다.

  @override
  void initState() {
    super.initState();
    _fetchOtherUserInfo();
  }

  void _fetchOtherUserInfo() async {
    var docSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (docSnapshot.exists) {
      setState(() {
        otherUser = UserModel.fromDocument(docSnapshot);
      });
    } else {
      print('사용자 정보를 찾을 수 없습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: otherUser == null
          ? const Center(child: CircularProgressIndicator()) // 사용자 정보를 불러오는 동안 로딩 인디케이터를 표시합니다.
          : ListView(
        children: [
          UserInfoSection(
            nickname: otherUser!.nickname,
            imageUrl: otherUser!.profileImageUrl,
            age: otherUser!.age,
            gender: otherUser!.gender,
            mannerTemperature: otherUser!.mannerTemperature,
          ),
          const Divider(),
          ListTile(
            title: const Text('배지 정보 조회'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserBadgeScreen(
                    badgeList: otherUser!.badgeList, // 다른 사용자의 배지 리스트 전달
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('받은 매너 평가'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserMannerScreen(
                    mannerList: otherUser!.mannerList ?? [],
                    unmannerlyList: otherUser!.unmannerList ?? [],
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('신고하기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportUserScreen(reportedUserId: widget.userId, reportedUserName: otherUser!.nickname),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}