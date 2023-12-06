import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kumoh_road/models/user_model.dart';
import 'package:logger/logger.dart';

class TaxiScreenUserModel extends UserModel{
  TaxiScreenUserModel({
    required String userId,
    required String nickname,
    required String profileImageUrl,
    required int age,
    required String gender,
    required double mannerTemperature,
    required List<Map<String, dynamic>>? mannerList,
    required List<Map<String, dynamic>>? unmannerList,
    required String? qrCodeUrl,
    required List<int> badgeList,
    required int commentCount,
    required int postCount,
    required int postCommentCount,
    required int reportCount,
    bool isStudentVerified = false,
  }) : super(
      userId: userId,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
      age: age,
      gender: gender,
      mannerTemperature: mannerTemperature,
      mannerList: mannerList,
      unmannerList: unmannerList,
      qrCodeUrl: qrCodeUrl,
      isStudentVerified: isStudentVerified,
      badgeList: badgeList,
      commentCount: commentCount,
      postCount: postCount,
      postCommentCount: postCommentCount,
      reportCount: reportCount
  );

  factory TaxiScreenUserModel.fromUserModel(UserModel userModel) {
    return TaxiScreenUserModel(
      userId: userModel.userId,
      nickname: userModel.nickname,
      profileImageUrl: userModel.profileImageUrl,
      age: userModel.age,
      gender: userModel.gender,
      mannerTemperature: userModel.mannerTemperature,
      mannerList: userModel.mannerList,
      unmannerList: userModel.unmannerList,
      qrCodeUrl: userModel.qrCodeUrl,
      isStudentVerified: userModel.isStudentVerified,
      badgeList: userModel.badgeList,
      commentCount: userModel.commentCount,
      postCount: userModel.postCount,
      postCommentCount: userModel.postCommentCount,
      reportCount: userModel.reportCount,
    );
  }

  static Future<TaxiScreenUserModel> getUserById(String writerId) async {
    DocumentSnapshot writerSnapshot = await FirebaseFirestore.instance.collection('users').doc(writerId).get();
    UserModel userModel = UserModel.fromDocument(writerSnapshot);
    TaxiScreenUserModel result = TaxiScreenUserModel.fromUserModel(userModel);

    return result;
  }

  static Future<List<TaxiScreenUserModel>> getUserList(List<String> userIdList) async {
    Logger log = Logger(printer: PrettyPrinter());
    try{
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      List<TaxiScreenUserModel> userList = [];
      for(var id in userIdList){
        for(var doc in snapshot.docs){
          if(userIdList.contains(doc.id)){
            userList.add(TaxiScreenUserModel.fromUserModel(UserModel.fromDocument(doc)));
          }
        }
      }
      return userList;
    }on Exception catch(e){
      log.e(e);
      return [];
    }
  }

  static Future<List<TaxiScreenUserModel>> getCommentUserList(List<String> commentUserIdList) async {
    Logger log = Logger(printer: PrettyPrinter());
    try{
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      List<TaxiScreenUserModel> userList = [];
      for(String id in commentUserIdList){
        final addUserDoc = snapshot.docs.firstWhere((userDoc) => id == userDoc.id);
        userList.add(TaxiScreenUserModel.fromUserModel(UserModel.fromDocument(addUserDoc)));
      }

      return userList;
    }on Exception catch(e){
      log.e(e);
      return [];
    }
  }
}
