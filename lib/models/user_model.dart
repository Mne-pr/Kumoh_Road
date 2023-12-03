import 'package:cloud_firestore/cloud_firestore.dart';
/**
 * 여러 화면에서 편하게 사용자 정보를 담을 수 있도록 한다.
 *  var docSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (docSnapshot.exists) {
      setState(() {
      otherUser = UserModel.fromDocument(docSnapshot);
      });
    } else {
      print('사용자 정보를 찾을 수 없습니다');
    }
 */
class UserModel {
  String userId;
  String nickname;
  String profileImageUrl;
  int age;
  String gender;
  double mannerTemperature;
  List<Map<String, dynamic>>? mannerList;
  List<Map<String, dynamic>>? unmannerList;
  String? qrCodeUrl;
  bool isStudentVerified;
  bool isSuspended;
  List<int> badgeList;
  int postCount;
  int postCommentCount;
  int commentCount;
  int reportCount;

  UserModel({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.age,
    required this.gender,
    required this.mannerTemperature,
    this.mannerList,
    this.unmannerList,
    this.qrCodeUrl,
    this.isStudentVerified = false,
    this.isSuspended = false,
    required this.badgeList,
    required this.postCount,
    required this.postCommentCount,
    required this.commentCount,
    required this.reportCount,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      nickname: data['nickname'] ?? 'N/A',
      profileImageUrl: data['profileImageUrl'] ?? 'https://k.kakaocdn.net/dn/1G9kp/btsAot8liOn/8CWudi3uy07rvFNUkk3ER0/img_640x640.jpg',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? 'N/A',
      mannerTemperature: (data['mannerTemperature'] ?? 0).toDouble(),
      mannerList: List<Map<String, dynamic>>.from(data['mannerList'] ?? []),
      unmannerList: List<Map<String, dynamic>>.from(data['unmannerList'] ?? []),
      qrCodeUrl: data['qrCodeUrl'],
      isStudentVerified: data['isStudentVerified'] ?? false,
      isSuspended: data['isSuspended'] ?? false,
      badgeList: List<int>.from(data['badgeList'] ?? [0, 0, 0, 0, 0, 0, 0, 0, 0]),
      postCount: data['postCount'] ?? 0,
      postCommentCount: data['postCommentCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
    );
  }
}

