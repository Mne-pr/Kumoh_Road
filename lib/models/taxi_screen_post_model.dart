import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiScreenPostModel {
  final String writerId;
  final String title;
  final String content;
  final DateTime createdTime;
  final int viewCount;
  final String imageUrl;
  final List<dynamic> membersIdList;

  TaxiScreenPostModel({
    required this.writerId,
    required this.title,
    required this.content,
    required this.createdTime,
    required this.viewCount,
    required this.imageUrl,
    required this.membersIdList,
  });

  static Future<List<TaxiScreenPostModel>> getAllPostsByCollectionName(
      String collectionName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
    List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    List<TaxiScreenPostModel> postList = documents.map((doc) => TaxiScreenPostModel(
            writerId: doc["writer"],
            title: doc["title"],
            content: doc["content"],
            createdTime: doc["createdTime"].toDate(),
            viewCount: doc["viewCount"],
            imageUrl: doc["image"],
            membersIdList: doc["members"]))
        .toList();

    return postList;
  }
}
