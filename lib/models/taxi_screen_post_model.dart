import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class TaxiScreenPostModel {
  final String categoryTime;
  final List<dynamic> commentList;
  final String content;
  final DateTime createdTime;
  final String imageUrl;
  final List<dynamic> memberList;
  final String title;
  final int viewCount;
  final bool visible;
  final String writerId;

  TaxiScreenPostModel({
    required this.categoryTime,
    required this.commentList,
    required this.content,
    required this.createdTime,
    required this.imageUrl,
    required this.memberList,
    required this.title,
    required this.viewCount,
    required this.visible,
    required this.writerId
  });

  factory TaxiScreenPostModel.fromDocSnap(DocumentSnapshot docSnap){
    try{
      return TaxiScreenPostModel(
          categoryTime: docSnap.data().toString().contains('categoryTime') ? docSnap['categoryTime'] : '',
          commentList: docSnap.data().toString().contains('commentList') ? docSnap['commentList'] : [],
          content: docSnap.data().toString().contains('content') ? docSnap['content'] : '',
          createdTime: docSnap.data().toString().contains('createdTime') ? (docSnap['createdTime'] as Timestamp).toDate() : DateTime(9999,99,99),
          imageUrl: docSnap.data().toString().contains('imageUrl') ? docSnap['imageUrl'] : '',
          memberList: docSnap.data().toString().contains('memberList') ? docSnap['memberList'] : [],
          title: docSnap.data().toString().contains('title') ? docSnap['title'] : '',
          viewCount: docSnap.data().toString().contains('viewCount') ? docSnap['viewCount'] : 0,
          visible: docSnap.data().toString().contains('visible') ? docSnap['visible'] : false,
          writerId: docSnap.data().toString().contains('writerId') ? docSnap['writerId'] : ''

      );
    }on Exception catch(e){
      rethrow;
    }
  }

  static Future<String> getDocId(
      {required String collectionId, required String writerId, required DateTime createdTime}) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
          collectionId)
          .where("createdTime", isEqualTo: createdTime)
          .where("writerId", isEqualTo: writerId)
          .get();

      return querySnapshot.docs.first.id;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<TaxiScreenPostModel>> getAllPostsByCollectionName(
      String collectionName) async {
    Logger log = Logger(printer: PrettyPrinter());
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
          collectionName).get();
      List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) =>
      doc.data() as Map<String, dynamic>).toList();
      List<TaxiScreenPostModel> postList = documents.map((doc) =>
          TaxiScreenPostModel(
              categoryTime: doc["categoryTime"],
              commentList: doc["commentList"],
              content: doc["content"],
              createdTime: (doc["createdTime"] as Timestamp).toDate(),
              imageUrl: doc["imageUrl"],
              memberList: doc["memberList"],
              title: doc["title"],
              viewCount: doc["viewCount"],
              visible: doc["visible"],
              writerId: doc["writerId"]
          )).toList();

      return postList;
    } on Exception catch (e) {
      log.e(e);

      return [];
    }
  }

  static Future<List<TaxiScreenPostModel>> getAllPostByCollectionAndDateTime(
      String collectionId, String categoryTime, DateTime today) async {
    Logger log = Logger(printer: PrettyPrinter());
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
          collectionId)
          .where("categoryTime", isEqualTo: categoryTime)
          .where("createdTime",
          isGreaterThanOrEqualTo: DateTime(today.year, today.month, today.day),
          isLessThan: DateTime(today.year, today.month, today.day + 1))
          .get();
      List<Map<String, dynamic>> documents = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      List<TaxiScreenPostModel> postList = documents.map((doc) =>
          TaxiScreenPostModel(
              categoryTime: doc["categoryTime"],
              commentList: doc["commentList"],
              content: doc["content"],
              createdTime: (doc["createdTime"] as Timestamp).toDate(),
              imageUrl: doc["imageUrl"],
              memberList: doc["memberList"],
              title: doc["title"],
              viewCount: doc["viewCount"],
              visible: doc["visible"],
              writerId: doc["writerId"]
          )).toList();

      return postList;
    } on Exception catch (e) {
      log.e(e);

      return [];
    }
  }
}
