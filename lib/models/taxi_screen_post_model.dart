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

  static Future<List<TaxiScreenPostModel>> getAllPostsByCollectionName(String collectionName) async {
    Logger log = Logger(printer: PrettyPrinter());
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
      List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      List<TaxiScreenPostModel> postList = documents.map((doc) => TaxiScreenPostModel(
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

    } on Exception catch(e){
      log.e(e);

      return [];
    }
  }

  static Future<List<TaxiScreenPostModel>> getAllPostByCollectionAndTime(String collectionId, String categoryTime) async {
    Logger log = Logger(printer: PrettyPrinter());
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionId)
          .where("categoryTime", isEqualTo: categoryTime)
          .get();
      List<Map<String, dynamic>> documents = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      List<TaxiScreenPostModel> postList = documents.map((doc) => TaxiScreenPostModel(
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

    } on Exception catch(e){
      log.e(e);

      return [];
    }
  }
}
