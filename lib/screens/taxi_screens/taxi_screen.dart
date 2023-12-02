
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_arrive_info_model.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/screens/taxi_screens/post_create_screen.dart';
import 'package:kumoh_road/screens/taxi_screens/post_details_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../providers/user_providers.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/loding_indicator_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';


class TaxiScreen extends StatefulWidget {
  const TaxiScreen({Key? key}) : super(key: key);

  @override
  _TaxiScreenState createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  String _selectedStartInfo = "금오공과대학교";
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final log = Logger(printer: PrettyPrinter());
    final userProvider = Provider.of<UserProvider>(context);
    final List<String> startList = ['금오공과대학교', '구미종합터미널', '구미역'];
    bool isChoicedKumoh = (_selectedStartInfo == "금오공과대학교");

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStartInfo(context, startList),
                isChoicedKumoh
                    ? _buildSchoolInfo(context)
                    : FutureBuilder(
                        future: _buildTrainOrBusArrivalInfo(context),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data ?? const Center(child: Text('게시글이 없습니다'));
                          } else if (snapshot.hasError) {
                            log.e(snapshot.error);
                            log.e(snapshot.stackTrace);
                            return const Text("도착정보 로딩 실패");
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                  ),
              ],
            ),
            const Divider(),
            FutureBuilder(
              future: _fetchAndBuildPosts(context),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: Center(child: LoadingIndicatorWidget()));
                } else if (snapshot.hasError) {
                  log.e("${snapshot.error}");
                  log.e("${snapshot.stackTrace}");
                  return const Center(child: Text("게시글을 불러올 수 없습니다"));
                } else if (snapshot.hasData) {
                  return snapshot.data ?? const Center(child: Text('게시글이 없습니다'));
                } else {
                  return const Center(child: Text('게시글이 없습니다'));
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
      floatingActionButton: writingButton(userProvider.isStudentVerified, context),
    );
  }

  Widget writingButton(bool studentVerified, BuildContext context){
    const Map<String, String> converter = {
      '금오공과대학교': 'school_posts',
      '구미종합터미널': 'express_bus_posts',
      '구미역': 'train_posts'
    };

    return FloatingActionButton.extended(
        onPressed: studentVerified ? () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return PostCreateScreen(converter[_selectedStartInfo]!, _selectedTime!);
          }));}
            : null,
        icon: const Icon(Icons.add),
        label: Text(
          "글쓰기",
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.2
          ),
        ),
        backgroundColor: studentVerified ? Theme.of(context).primaryColor : Colors.grey
    );
  }

  Widget _buildStartInfo(BuildContext context, List<String> startList) {
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;

    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.04),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(
              fontSize: defaultFontSize * 1.1,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          value: _selectedStartInfo,
          onChanged: (String? newValue) {
            setState(() {
              _selectedStartInfo = newValue!;
            });
          },
          items: startList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSchoolInfo(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;

    // DB의 기존 게시글 가져오기
    DateTime now = DateTime.now();
    List<int> timeList = [now.hour];
    for(int i = 1; i <=3; i++){
      int hour = now.hour + i;
      if(hour >= 24) {
        continue;
      }
      timeList.add(hour);
    }

    List<String> showTimeList = timeList.map((e) => e < 10 ? "0$e:00" : "$e:00")
        .toList();
    if(!showTimeList.contains(_selectedTime)) {
      _selectedTime = showTimeList[0];
    }
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.02),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(
              fontSize: defaultFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          value: _selectedTime,
          onChanged: (String? newValue) {
            setState(() {
              _selectedTime = newValue!;
            });
          },
          items: showTimeList.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<Widget> _buildTrainOrBusArrivalInfo(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;

    bool isChoicedGumiStation = _selectedStartInfo == "구미역";
    final String collectionId = isChoicedGumiStation ? "train_arrival_info" : "exbus_arrival_info";

    List<ArriveInfo> arriveInfoList = [];

    // DB의 도착정보 가져오기
    if (isChoicedGumiStation) {
      arriveInfoList = await ArriveInfo.fetchTrainArriveInfoFromDb();
    } else {
      arriveInfoList = await ArriveInfo.fetchBusArriveInfoFromDb();
    }

    DateTime now = DateTime.now();
    DateTime saveDay = arriveInfoList[0].arriveDateTime;
    bool isSameDate = now.year == saveDay.year && now.month == saveDay.month && now.day == saveDay.day;
    // if) DB의 도착 정보 != 오늘 날짜
    if (!isSameDate) {
      List<ArriveInfo> putArriveInfoList = [];

      Fluttertoast.showToast(
        msg: "데이터를 로딩 중입니다\n기다려 주세요!!!!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        fontSize: defaultFontSize,
      );

      // api에서 오늘 도착정보 가져오기
      if (isChoicedGumiStation) {
        putArriveInfoList = await ArriveInfo.getTrainArriveInfoFromApi();
      } else {
        putArriveInfoList = await ArriveInfo.getBusArriveInfoFromApi();
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // 기존의 도착 정보 삭제
      final WriteBatch batch = firestore.batch();
      final QuerySnapshot querySnapshot = await firestore.collection(collectionId).get();
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        batch.delete(document.reference);
      }

      putArriveInfoList = putArriveInfoList // 중복된 시간 제거(고속버스와 시외버스의 도착시간 정보가 겹칠 경우 대비)
          .map((e) => '${e.arriveDateTime.hour}:${e.arriveDateTime.minute}')
          .toSet()
          .map((e) {
        List<String> timeParts = e.split(':');
        DateTime aTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
        return ArriveInfo(arriveDateTime: aTime);
      }).toList();
      // 오늘 도착 정보를 DB에 저장
      for (int i = 0; i < putArriveInfoList.length; i++) {
        ArriveInfo arriveInfo = putArriveInfoList[i];
        batch.set(firestore.collection(collectionId).doc(i.toString()), {'arriveDateTime': arriveInfo.arriveDateTime});
      }
      // 삭제와 저장 쿼리 모았다가 한번에 전송
      await batch.commit();
    }
    // DB의 오늘 도착 정보 가져오기
    if (isChoicedGumiStation) {
      arriveInfoList = await ArriveInfo.fetchTrainArriveInfoFromDb();
    } else {
      arriveInfoList = await ArriveInfo.fetchBusArriveInfoFromDb();
    }

    final log = Logger(printer: PrettyPrinter());
    if (arriveInfoList.isEmpty) {
      log.e("DB에서 도착정보 불러오기 실패함");
      return const Text("도착 정보 불러오기 실패");
    }

    arriveInfoList.sort((a, b) => a.arriveDateTime.compareTo(b.arriveDateTime)); //DB 데이터는 미정렬 데이터라서
    // 현재 이후 시간만 모으기
    List<ArriveInfo> afterArriveInfoList = arriveInfoList
        .where((ArriveInfo e) => e.arriveDateTime.isAfter(now))
        .toList();

    if(afterArriveInfoList.isEmpty){
      return const Text("현재 이후 도착정보 없음");
    }

    // 현재와 가까운 시간 최대 7개까지 필터링
    List<ArriveInfo> showArriveInfoList = afterArriveInfoList.take(7).toList();
    // 출력할 시간 리스트(hh:mm 형식)
    List<String> showArriveTimeList = showArriveInfoList
        .map((e) {
          String hour = e.arriveDateTime.hour < 10 ? "0${e.arriveDateTime.hour}" : "${e.arriveDateTime.hour}";
          String minute = e.arriveDateTime.minute < 10 ? "0${e.arriveDateTime .minute}" : "${e.arriveDateTime.minute}";
          return "$hour:$minute";
        }).toList();

    if(!showArriveTimeList.contains(_selectedTime)) {
      _selectedTime = showArriveTimeList[0];
    }

    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.02),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(
              fontSize: defaultFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          value: _selectedTime,
          onChanged: (String? newValue) {
            setState(() {
              _selectedTime = newValue!;
            });
          },
          items: showArriveTimeList.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<Widget> _fetchAndBuildPosts(BuildContext context) async {
    String collectionName = "";
    if (_selectedStartInfo == "금오공과대학교") {
      collectionName = "school_posts";
    } else if (_selectedStartInfo == "구미종합터미널") {
      collectionName = "express_bus_posts";
    } else if (_selectedStartInfo == "구미역") {
      collectionName = "train_posts";
    }

    List<ArriveInfo> arriveInfoList = [];
    // DB의 기존 게시글 가져오기(DB 학교 게시판의 글과 오늘 날짜 비교를 위한 작업)
    arriveInfoList = await ArriveInfo.fetchSchoolCreatedTime();
    DateTime now = DateTime.now();

    if(arriveInfoList.isNotEmpty){
      DateTime saveDay = arriveInfoList[0].arriveDateTime;
      bool isSameDate = now.year == saveDay.year && now.month == saveDay.month && now.day == saveDay.day;
      if (!isSameDate) {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        // 기존의 학교 게시글 정보 삭제
        final WriteBatch batch = firestore.batch();
        final QuerySnapshot querySnapshot = await firestore.collection("school_posts").get();
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          batch.delete(document.reference);
        }
        await batch.commit(); // 쿼리 일괄 전송
      }
    }

    // 현재 출발지와 현재 선택한 시간(categoryTime 필드)인 모든 게시글 읽어오기
    List<TaxiScreenPostModel> postList = await TaxiScreenPostModel.getAllPostByCollectionAndTime(collectionName, _selectedTime!);

    return _buildPosts(context, postList);
  }

  Future<Widget> _buildPosts(BuildContext context, List<TaxiScreenPostModel> postList) async {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    double imageHeight = screenHeight * 0.2;
    double contentFontSize = defaultFontSize;
    EdgeInsets leftPadding = EdgeInsets.only(left: screenWidth * 0.01);

    // 선택한 시간의 등록된 게시물이 없을 시
    if(postList.isEmpty) {
      return const Center(child: Text("게시물을 등록해주세요!"),);
    }

    // 모든 작성자 정보를 읽어오기
    List<String> userIdList = postList
        .map((e) => e.writerId)
        .toList();
    List<TaxiScreenUserModel> writerList = await TaxiScreenUserModel.getUserList(userIdList);

    return Expanded(
      child: ListView.builder(
        itemCount: postList.length,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        itemBuilder: (context, int index) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  //todo: 상세 페이지 이동
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10)),
                      child: Hero(
                        tag: index,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors
                                  .grey, // Change border color as needed
                              width: 0.1, // Change border width as needed
                            ),
                          ),
                          child: postList[index].imageUrl.isEmpty
                              ? Image.asset(
                            'assets/images/default_avatar.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                            )
                              : Image.network(
                            postList[index].imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, top: 2),
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              postList[index].title,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                            ),
                            Row(
                              children: [
                                Text(
                                  "${writerList[index].nickname}(${writerList[index].gender}) ",
                                  style: const TextStyle(
                                    color: Colors.grey
                                  ),
                                ),
                                Text(
                                  "${DateTime.now().difference(postList[index].createdTime).inMinutes}분전"
                                )
                              ],
                            ),
                            Text(
                              "${postList[index].memberList.length + 1}/4",
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.1,
                                color: Theme.of(context).primaryColor
                              ),
                            ),
                            Row(
                              children: [
                                const Spacer(), // Row의 나머지 공간을 채워 아이콘을 오른쪽으로 밀어냄
                                const Icon(Icons.rate_review_outlined, color: Colors.grey), // 사용하고자 하는 아이콘으로 변경
                                Text("${postList[index].commentList.length}"), // 실제 댓글 수를 나타내는 필드로 변경
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.1,
                height: 1,
              ),
            ],
          );
        },
      ),
    );
  }
}

