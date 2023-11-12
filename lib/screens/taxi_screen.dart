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
  String _selectedVehicle = '버스'; // 상단의 선택된 버튼 상태
  final _arrivalsInformations = <String>['정보1', '정보2', '정보3'];
  String? _selectedArrivalInfo;

  @override
  void initState() {
    super.initState();
    _selectedArrivalInfo = _arrivalsInformations[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildArrivalInfoDropDownButton(context),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    children: [
                      _buildToggleButton(context, '버스'),
                      _buildToggleButton(context, '기차'),
                    ],
                  ),
                ),
                //TODO: 검색 버튼 만들기
                //TODO: 메뉴 버튼 만들기
                //TODO: 알림 모양 버튼 만들기
              ],
            ),
            const Divider(),
            FutureBuilder(
                future: _buildPosts(context),
                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if(snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return snapshot.data!;
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

  Widget _buildToggleButton(BuildContext context, String argTitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 5),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedVehicle = argTitle;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: _selectedVehicle == argTitle
              ? const Color(0xFF3F51B5)
              : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          side: BorderSide(color: _selectedVehicle == argTitle
              ? const Color(0xFF3F51B5)
              : Colors.black12),
        ),
        child: Text(
          argTitle,
          style: TextStyle(
            color: _selectedVehicle == argTitle ? Colors.white : Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _buildArrivalInfoDropDownButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black),
            value: _selectedArrivalInfo,
            onChanged: (String? newValue) {
              setState(() {
                _selectedArrivalInfo = newValue!;
              });
            },
            // TODO: DB의 버스 또는 기차 게시글 읽어서 넣기
            items: _arrivalsInformations.map<
                DropdownMenuItem<String>>((String value) {
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

  Future<Widget> _buildPosts(BuildContext context) async {
    double imgHeight = MediaQuery.of(context).size.height / 6 - 16; // 게시글 5개 정도만 보이도록

    String collectionName = "";
    if(_selectedVehicle == "버스") {
      collectionName = "express_bus_posts";
    } else if(_selectedVehicle == "기차") {
      collectionName = "train_posts";
    }
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
    List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    print(documents[0]);

    return Expanded(
      child: ListView.separated(
        itemCount: documents.length, // TODO: 실제 DB 데이터 크기로 변경
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          String title = documents[index]["title"];
          DateTime createdTime = documents[index]["createdTime"].toDate();
          List members = documents[index]["members"];
          String writerId = documents[index]["writer"];

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
                          Text(
                            '${createdTime.hour}시 ${createdTime.minute}분',
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