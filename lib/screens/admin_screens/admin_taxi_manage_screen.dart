import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:provider/provider.dart';
import '../../widgets/report_count_widget.dart';
import 'admin_taxi_post_detail_screen.dart';
import '../../providers/user_providers.dart';
import '../../widgets/admin_bottom_navigation_bar.dart';
import 'admin_user_info_screen.dart';

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
  final List<String> _manageOptions = ['택시 게시글 관리', '택시 댓글 관리'];
  String _selectedOption = '택시 게시글 관리';

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

  Widget _buildContentSection() {
    if (_selectedOption == '택시 게시글 관리') {
      return _postListSection();
    } else {
      return _commentList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: _selectedOption,
          underline: Container(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedOption = newValue!;
            });
          },
          items: _manageOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: _buildContentSection(),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: Transform.scale(
            alignment: Alignment.bottomRight,
            scale: 1.4,
          ),
        ),
      ),
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
    var documents = await firestore.collection('reports')
        .where('entityType', isEqualTo: 'post')
        .where('isHandledByAdmin', isEqualTo: false)
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
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AdminPostDetailScreen(postModel: postModel, entityId: entityId, writerModel: writerModel, documents: querySnapshot)
          )).then((_) {
            setState(() {
              _postList();
            });
          });
        },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                  const SizedBox(height: 5), // 제목과 작성자 정보 사이 간격 추가
                  Text(
                    "${writerModel.nickname} (${writerModel.gender})",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    timeText,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5), // 작성자 정보와 참여 인원 사이 간격 추가
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
                      ReportCountWidget(querySnapshot.docs.length),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reports')
          .where('entityType', isEqualTo: 'postComment')
          .where('isHandledByAdmin', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("데이터가 없습니다."));
        }

        // 댓글 ID 별로 중복 제거
        var uniqueCommentIds = snapshot.data!.docs
            .map((doc) => (doc.data() as Map<String, dynamic>)['entityId'])
            .toSet()
            .toList();

        return ListView.builder(
          itemCount: uniqueCommentIds.length,
          itemBuilder: (context, index) {
            DocumentSnapshot reportDoc = snapshot.data!.docs[index];
            String entityId = uniqueCommentIds[index];
            List<String> entityParts = entityId.split(':');
            String collectionName = entityParts[0];
            String postId = entityParts[1];
            String commentId = entityParts[2];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection(collectionName).doc(postId).get(),
              builder: (context, postSnapshot) {
                if (!postSnapshot.hasData) return const SizedBox.shrink();

                Map<String, dynamic> postData = postSnapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> comments = postData['commentList'];
                var comment = comments.firstWhere((c) => c['id'] == commentId, orElse: () => null);
                if (comment == null) return const SizedBox.shrink();

                String userId = comment['user_code'];

                // Fetch report counts for the comment
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('reports')
                      .where('entityId', isEqualTo: entityId)
                      .get(),
                  builder: (context, reportSnapshot) {
                    if (!reportSnapshot.hasData) return const SizedBox.shrink();

                    int reportCount = reportSnapshot.data!.docs.length;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return const SizedBox.shrink();

                        Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        String userName = userData['nickname'];
                        String userProfileUrl = userData['profileImageUrl'];
                        double mannerTemperature = userData['mannerTemperature'];

                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Dismissible(
                            key: Key(commentId),
                            background: Container(
                              color: Colors.grey,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: const Color(0xFF3F51B5),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.visibility_off, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                _blindComment(collectionName, postId, commentId, reportDoc.id);
                              } else {
                                _ignoreReport(reportDoc.id);
                              }
                              // Remove the item from the uniqueCommentIds list
                              setState(() {
                                uniqueCommentIds.removeAt(index);
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 3.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: ListTile(
                                  leading: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminUserInfoScreen(userId: userId),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundImage: NetworkImage(userProfileUrl),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              userName,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            ReportCountWidget(reportCount),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '$mannerTemperature°C',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _getTemperatureColor(mannerTemperature),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      _getTemperatureEmoji(mannerTemperature),
                                    ],
                                  ),
                                  subtitle: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(comment['comment']),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 5.0),
                                            child: _buildMannerBar(mannerTemperature),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }


  Color _getTemperatureColor(double temperature) {
    if (temperature >= 37.5) {
      return Colors.red;
    } else if (temperature >= 36.5) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Widget _getTemperatureEmoji(double temperature) {
    String emoji;
    if (temperature >= 37.5) {
      emoji = '🥵';
    } else if (temperature >= 36.5) {
      emoji = '😊';
    } else {
      emoji = '😨';
    }
    return Text(emoji);
  }

  Widget _buildMannerBar(double temperature) {
    return Container(
      width: 100, // 매너 막대 너비 고정
      height: 8, // 매너 막대 높이
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: temperature / 100,
          backgroundColor: Colors.grey[300],
          color: _getTemperatureColor(temperature),
          minHeight: 6,
        ),
      ),
    );
  }

  Future<void> _blindComment(String collectionName, String postId, String commentId, String reportId) async {
    var postDocument = await FirebaseFirestore.instance.collection(collectionName).doc(postId).get();
    var comments = List<Map<String, dynamic>>.from(postDocument.data()!['commentList']);
    var commentIndex = comments.indexWhere((c) => c['id'] == commentId);
    if (commentIndex != -1) {
      comments[commentIndex]['enable'] = false;
      await FirebaseFirestore.instance.collection(collectionName).doc(postId).update({'commentList': comments});
    }
    await _handleReport(reportId);
  }

  Future<void> _ignoreReport(String reportId) async {
    await _handleReport(reportId);
  }

  Future<void> _handleReport(String reportId) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).update({'isHandledByAdmin': true});
  }
}
