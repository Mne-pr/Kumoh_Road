import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiScreenUserModel {
  int age;
  String email;
  String gender;
  double mannerTemperature;
  String nickname;
  String profileImageUrl;
  String? qrCodeUrl;
  bool? studentVerified;
  List<dynamic> mannerList;
  List<dynamic> unmannerList;
  List<dynamic> reviewList;

  TaxiScreenUserModel(
      {required this.age,
      required this.email,
      required this.gender,
      required this.mannerList,
      required this.mannerTemperature,
      required this.nickname,
      required this.profileImageUrl,
      required this.qrCodeUrl,
      required this.studentVerified,
      required this.reviewList,
      required this.unmannerList});

  static Future<TaxiScreenUserModel> getUserById(String writerId) async {
    DocumentSnapshot writerSnapshot = await FirebaseFirestore.instance.collection('users').doc(writerId).get();
    Map<String, dynamic> document = writerSnapshot.data() as Map<String, dynamic>;
    return TaxiScreenUserModel(
        age: document["age"] ?? 20,
        email: document["email"],
        gender: document["gender"] ?? "성별없음",
        mannerTemperature: document["mannerTemperature"],
        nickname: document["nickname"],
        profileImageUrl: document["profileImageUrl"],
        qrCodeUrl: document["qrCodeUrl"] ?? "",
        studentVerified: document["studentVerified"] ?? false,
        mannerList: document["mannerList"],
        unmannerList: document["unmannerList"],
        reviewList: document["reviewList"],
    );
  }
}
