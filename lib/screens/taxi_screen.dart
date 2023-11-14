import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kakao_login_providers.dart';
import '../widgets/bottom_navigation_bar.dart';

class TaxiScreen extends StatefulWidget {
  const TaxiScreen({Key? key}) : super(key: key);

  @override
  _TaxiScreenState createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  final _startList = <String>['금오공과대학교', '구미종합터미널', '구미역'];
  String _selectedStartInfo = "금오공과대학교";
  bool _isSelectedKumohUniversity = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStartInfo(context),
                // TODO: 도착 시간 정보 dropDownButton 만들기
                if (!_isSelectedKumohUniversity) _buildArrivalInfo(context)
                //TODO: 검색 버튼 만들기
              ],
            ),
            const Divider(),
            FutureBuilder(
                future: _fetchAndBuildPosts(context),
                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  else if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));
                  else if (snapshot.hasData)
                    return snapshot.data!;
                  else
                    return const Center(child: Text('No data available'));
                  }
            )
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 게시글 추가
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStartInfo(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            style: const TextStyle(
                fontSize: 20, // 폰트 크기 수정
                fontWeight: FontWeight.bold,
                color: Colors.black),
            value: _selectedStartInfo,
            onChanged: (String? newValue) {
              setState(() {
                _selectedStartInfo = newValue ?? "invalid source";
                _isSelectedKumohUniversity = newValue == "금오공과대학교";
              });
            },
            items: _startList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildArrivalInfo(BuildContext context){
    /*
    * 1. _selectedStartInfo에 따라서 API에서 데이터를 읽기
    * 2. 현재 시간 이후의 데이터만 드롭다운 버튼으로 출력하기
    * */
    return Center(child: Text("도착 정보"));
  }

  Future<Widget> _fetchAndBuildPosts(BuildContext context) async {
    double imgHeight = MediaQuery.of(context).size.height / 6 - 16;
    String collectionName = "";

    if(_selectedStartInfo == "금오공과대학교") collectionName = "school_posts";
    else if(_selectedStartInfo == "구미종합터미널") collectionName = "express_bus_posts";
    else if(_selectedStartInfo == "구미역") collectionName = "train_posts";
    //else // TODO: 예외 던지기(공부 후)

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
    List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // Fetch writer's details for all documents
    Map<String, Map<String, dynamic>> writersDetails = {};
    for (var document in documents) {
      String writerId = document["writer"]; // 각 게시글의 방장 id 읽기
      DocumentSnapshot writerSnapshot = await FirebaseFirestore.instance.collection('users').doc(writerId).get(); // 방장 유저 정보 읽기
      writersDetails[writerId] = writerSnapshot.data() as Map<String, dynamic>;
    }

    return _buildPosts(context, documents, writersDetails, imgHeight);
  }

  Widget _buildPosts(BuildContext context, List<Map<String, dynamic>> documents, Map<String, Map<String, dynamic>> writersDetails, double imgHeight) {
    return Expanded(
      child: ListView.separated(
        itemCount: documents.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> document = documents[index];
          String title = document["title"];
          DateTime createdTime = document["createdTime"].toDate();
          List members = document["members"];
          String writerId = document["writer"];

          Map<String, dynamic>? writerDetails = writersDetails[writerId];
          String writerName = writerDetails?['nickname'] ?? 'no name';
          String writerGender = writerDetails?['gender'] ?? 'no gender';

          return Padding(
            padding: const EdgeInsets.only(left: 15),
            child: SizedBox(
              height: imgHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 게시글 이미지
                  AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(3)),
                        child: Image.network(
                          documents[index]["image"],
                          width: imgHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/images/default_avatar.png',
                              width: imgHeight,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //게시글 제목
                          Text(
                            title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // 글쓴이 및 생성 시간
                          Text( //
                            '${writerName}(${writerGender}) ${createdTime.hour}시 ${createdTime.minute}분',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 참여 인원 수
                          Text(
                            "${members.length + 1}/4",
                            style: const TextStyle(
                                color: Color(0xFF3F51B5),
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20,),
                          // 댓글 수
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.question_answer_outlined, color: Colors.grey),
                              Text('1'), // TODO: 실제 댓글 수 데이터로 변경
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}