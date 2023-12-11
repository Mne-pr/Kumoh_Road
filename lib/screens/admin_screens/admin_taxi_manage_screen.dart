import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:provider/provider.dart';
import '../../models/admin_taxi_post_detail_screen.dart';
import '../../providers/user_providers.dart';
import '../../widgets/admin_bottom_navigation_bar.dart';
import 'package:logger/logger.dart';

late UserProvider currUser;
late double deviceWidth;
late double deviceHeight;
late double deviceFontSize;
late Color mainColor;

class AdminTaxiManageScreen extends StatefulWidget {
  const AdminTaxiManageScreen({super.key});

  @override
  State<AdminTaxiManageScreen> createState() => _AdminTaxiManageScreenState();
}

final firestore = FirebaseFirestore.instance;

class _AdminTaxiManageScreenState extends State<AdminTaxiManageScreen> {
  bool _willShowPost = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    currUser = Provider.of<UserProvider>(context, listen: false);
    deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    deviceFontSize = Theme
        .of(context)
        .textTheme
        .bodyLarge!
        .fontSize!;
    mainColor = Theme
        .of(context)
        .primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("택시 게시글/댓글 관리", style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: _willShowPost ? _postListSection() : _commentList(),
      floatingActionButton: floatButton(),
      bottomNavigationBar: const AdminCustomBottomNavigationBar(
        selectedIndex: 1,
      ),
    );
  }

  Widget _postListSection() {
    return FutureBuilder(
      future: _postList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          log.e(snapshot.error);
          log.e(snapshot.stackTrace);
          return const Text("신고 게시글 로딩 실패");
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<Widget> _postList() async {
    // 신고 게시글 읽기
    var documents = await firestore.collection('reports')
        .where('entityType', isEqualTo: 'post')
        .get();
    var posts = filterDocs(documents); // 중복 entity id 문서 필터링

    return ListView.separated(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
              future: postItem(posts[index]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!;
                } else if (snapshot.hasError) {
                  log.e(snapshot.error);
                  log.e(snapshot.stackTrace);
                  return const Text("신고 게시글 로딩 실패");
                } else {
                  return const CircularProgressIndicator();
                }
              },
          );
        },
        separatorBuilder: (context, index) => const Divider(),
    );
  }

  List<String> filterDocs(QuerySnapshot querySnapshot){
    var entityList = querySnapshot.docs.map((e) => e['entityId'] as String).toList();

    return entityList.toSet().toList();
  }

  Future<Widget> postItem(String entityId) async{
      QuerySnapshot querySnapshot = await firestore.collection('reports') // 해당 게시물의 모든 신고 목록
        .where('entityId', isEqualTo: entityId)
        .get();
    String temp = querySnapshot.docs.first['entityId']; // 게시글 정보 얻기 위해서 한 개 빼옴

    String colId = temp.split(':')[0]; // entity id 분리
    String docId = temp.split(':')[1];
    var postDoc = await firestore.collection(colId).doc(docId).get();
    var postModel = TaxiScreenPostModel.fromDocSnap(postDoc); // post model
    var writerModel = await TaxiScreenUserModel.getUserById(postModel.writerId); // user model

    double imageSize = deviceWidth * 0.3;
    int minutesAgo = DateTime.now().difference(postModel.createdTime).inMinutes;
    String timeText = minutesAgo == 0 ? "방금 전" : "$minutesAgo분 전";

    return GestureDetector(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AdminPostDetailScreen(postModel: postModel, entityId: entityId, writerModel: writerModel, documents: querySnapshot)
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: postModel.imageUrl.isEmpty
                  ? Image.asset(
                'assets/images/default_avatar.png',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              )
                  : Image.network(
                postModel.imageUrl,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postModel.title,
                    style: TextStyle(fontSize: deviceFontSize * 1.2),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 5), // 제목과 작성자 정보 사이 간격 추가
                  Text(
                    "${writerModel.nickname} (${writerModel.gender})",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    timeText,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5), // 작성자 정보와 참여 인원 사이 간격 추가
                  Text(
                    "${postModel.memberList.length + 1}/4",
                    style: TextStyle(
                      fontSize: deviceFontSize * 1.1,
                      color: mainColor,
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      Transform.scale(
                        scale: 0.8,
                        child: const Icon(
                            Icons.warning_amber, color: Colors.redAccent),
                      ),
                      Text(
                          " ${querySnapshot.docs.length}"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentList() {
    return Container();
  }

  Widget floatButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _willShowPost = !_willShowPost;
        });
      },
      label: Text(_willShowPost ? "신고 댓글 보기" : "신고 게시글 보기"),
    );
  }


}
