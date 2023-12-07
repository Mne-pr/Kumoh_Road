import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../widgets/user_info_section.dart';
import '../user_info_screens/other_badge_screen.dart';
import '../user_info_screens/other_user_manner_screen.dart';

class AdminUserInfoScreen extends StatefulWidget {
  final String userId;

  const AdminUserInfoScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AdminUserInfoScreenState createState() => _AdminUserInfoScreenState();
}

class _AdminUserInfoScreenState extends State<AdminUserInfoScreen> {
  UserModel? otherUser;
  bool isSuspended = false;

  @override
  void initState() {
    super.initState();
    _listenToUserInfoChanges();
  }

  void _listenToUserInfoChanges() {
    FirebaseFirestore.instance.collection('users').doc(widget.userId)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          otherUser = UserModel.fromDocument(docSnapshot);
          isSuspended = otherUser!.isSuspended;
        });
      } else {
        print('사용자 정보를 찾을 수 없습니다');
      }
    }, onError: (error) => print("Listen failed: $error"));
  }

  Future<void> suspendUser(String userId) async {
    if (!isSuspended) {
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

      if (mounted) {
        setState(() {
          isSuspended = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 관리', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: otherUser == null
          ? const Center(child: CircularProgressIndicator())
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
            title: isSuspended
                ? const Text('사용자 계정 정지됨')// "Action Taken"
                : const Text('사용자 계정 정지'), // "Suspend Account"
            trailing: Icon(
                isSuspended ? Icons.lock : Icons.block
            ),
            onTap: isSuspended ? null : () {
              suspendUser(widget.userId);
            },
          ),
        ],
      ),
    );
  }
}
