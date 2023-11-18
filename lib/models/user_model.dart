import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  String nickname;
  String profileImageUrl;
  int age;
  String gender;
  double mannerTemperature;

  UserModel({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.age,
    required this.gender,
    required this.mannerTemperature,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return UserModel(
      nickname: data['nickname'] ?? 'N/A',
      profileImageUrl: data['profileImageUrl'] ?? 'https://k.kakaocdn.net/dn/1G9kp/btsAot8liOn/8CWudi3uy07rvFNUkk3ER0/img_640x640.jpg',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? 'N/A',
      mannerTemperature: data['mannerTemperature'].toDouble() ?? 0.0, userId: '',
    );
  }
}

