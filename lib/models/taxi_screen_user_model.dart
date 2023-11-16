class User{
  int age;
  String email;
  String gender;
  List<dynamic> mannerList;
  double mannerTemperature;
  String nickname;
  String profileImageUrl;
  String qrCodeUrl;
  bool studentVerified;
  List<dynamic> unmannerList;

  User({
    required this.age,
    required this.email,
    required this.gender,
    required this.mannerList,
    required this.mannerTemperature,
    required this.nickname,
    required this.profileImageUrl,
    required this.qrCodeUrl,
    required this.studentVerified,
    required this.unmannerList
  });
}