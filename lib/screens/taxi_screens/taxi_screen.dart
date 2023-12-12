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

Logger log = Logger(printer: PrettyPrinter());
late UserProvider currUser;
late double deviceWidth;
late double deviceHeight;
late double deviceFontSize;
late Color mainColor;

const Map<String, String> converter = {
  '금오공과대학교': 'school_posts',
  '구미종합터미널': 'express_bus_posts',
  '구미역': 'train_posts'
};

class TaxiScreen extends StatefulWidget {
  const TaxiScreen({Key? key}) : super(key: key);

  @override
  _TaxiScreenState createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  String _selectedStartInfo = "금오공과대학교";
  String? _selectedTime;
  bool _isExistingArrivalInfo = true;

  @override
  Widget build(BuildContext context) {
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
                      return snapshot.data!;
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
                if (snapshot.hasData) {
                  return snapshot.data!;
                } else if (snapshot.hasError) {
                  log.e(snapshot.error);
                  log.e(snapshot.stackTrace);
                  return const Text("게시글 로딩 실패");
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
      floatingActionButton: writingButton(context),
    );
  }

  Widget writingButton(BuildContext context) {
    return FloatingActionButton.extended(
        onPressed: () {
          validateWritingPermission();
        },
        icon: const Icon(Icons.add),
        label: Text(
          "글쓰기",
          style: TextStyle(
              fontSize: deviceFontSize * 1.2),
        ),
        backgroundColor:
        currUser.isStudentVerified && currUser.qrCodeUrl != null
            ? mainColor
            : Colors.grey);
  }

  void validateWritingPermission() {
    if (!currUser.isStudentVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학생인증을 해주세요')),
      );
      return;
    }
    if (currUser.qrCodeUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR등록을 해주세요')),
      );
      return;
    }
    if (!_isExistingArrivalInfo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('도착정보가 없어서 글쓰기를 할 수 없습니다')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return PostCreateScreen(
            converter[_selectedStartInfo]!, _selectedTime!);
      }),
    );
  }

  Widget _buildStartInfo(BuildContext context, List<String> startList) {
    return Padding(
      padding: EdgeInsets.only(left: deviceWidth * 0.04),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(
              fontSize: deviceFontSize * 1.1,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          value: _selectedStartInfo,
          onChanged: (String? newValue) {
            setState(() {
              if (newValue == "금오공과대학교") {
                _isExistingArrivalInfo = true;
              }
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
    // DB의 기존 게시글 가져오기
    DateTime now = DateTime.now();
    List<int> timeList = [now.hour];
    for (int i = 1; i <= 3; i++) {
      int hour = now.hour + i;
      if (hour >= 24) {
        hour = hour % 24;
      }
      timeList.add(hour);
    }

    List<String> showTimeList =
    timeList.map((e) => e < 10 ? "0$e:00" : "$e:00").toList();
    if (!showTimeList.contains(_selectedTime)) {
      _selectedTime = showTimeList[0];
    }
    return Padding(
      padding: EdgeInsets.only(left: deviceWidth * 0.02),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: TextStyle(
              fontSize: deviceFontSize,
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
    bool isChoicedGumiStation = _selectedStartInfo == "구미역";
    final String collectionId =
    isChoicedGumiStation ? "train_arrival_info" : "exbus_arrival_info";

    List<ArriveInfo> arriveInfoList = [];

    // DB의 도착정보 가져오기
    if (isChoicedGumiStation) {
      arriveInfoList = await ArriveInfo.fetchTrainArriveInfoFromDb();
    } else {
      arriveInfoList = await ArriveInfo.fetchBusArriveInfoFromDb();
    }

    DateTime now = DateTime.now();
    DateTime saveDay = arriveInfoList[0].arriveDateTime;
    bool isSameDate = now.year == saveDay.year &&
        now.month == saveDay.month &&
        now.day == saveDay.day;
    // if) DB의 도착 정보 != 오늘 날짜
    if (!isSameDate) {
      List<ArriveInfo> putArriveInfoList = [];
      // api에서 오늘 도착정보 가져오기
      if (isChoicedGumiStation) {
        putArriveInfoList = await ArriveInfo.getTrainArriveInfoFromApi();
      } else {
        putArriveInfoList = await ArriveInfo.getBusArriveInfoFromApi();
      }
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // 기존의 도착 정보 삭제
      final WriteBatch batch = firestore.batch();
      final QuerySnapshot querySnapshot =
      await firestore.collection(collectionId).get();
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        batch.delete(document.reference);
      }
      putArriveInfoList =
          putArriveInfoList // 중복된 시간 제거(고속버스와 시외버스의 도착시간 정보가 겹칠 경우 대비)
              .map((e) => '${e.arriveDateTime.hour}:${e.arriveDateTime.minute}')
              .toSet()
              .map((e) {
            List<String> timeParts = e.split(':');
            DateTime aTime = DateTime(now.year, now.month, now.day,
                int.parse(timeParts[0]), int.parse(timeParts[1]));
            return ArriveInfo(arriveDateTime: aTime);
          }).toList();
      // 오늘 도착 정보를 DB에 저장
      for (int i = 0; i < putArriveInfoList.length; i++) {
        ArriveInfo arriveInfo = putArriveInfoList[i];
        batch.set(firestore.collection(collectionId).doc(i.toString()),
            {'arriveDateTime': arriveInfo.arriveDateTime});
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

    if (arriveInfoList.isEmpty) {
      log.e("DB에서 도착정보 불러오기 실패함");
      return const Text("도착 정보 불러오기 실패");
    }

    arriveInfoList.sort((a, b) =>
        a.arriveDateTime.compareTo(b.arriveDateTime)); //DB 데이터는 미정렬 데이터라서
    // 현재 이후 시간만 모으기
    List<ArriveInfo> afterArriveInfoList = arriveInfoList
        .where((ArriveInfo e) => e.arriveDateTime.isAfter(now))
        .toList();

    if (afterArriveInfoList.isEmpty) {
      _isExistingArrivalInfo = false;
      log.i("도착정보 상태변수 변경 : $_isExistingArrivalInfo");

      return const Text("현재 이후 도착정보 없음");
    }

    // 현재와 가까운 시간 최대 7개까지 필터링
    List<ArriveInfo> showArriveInfoList = afterArriveInfoList.take(7).toList();
    // 출력할 시간 리스트(hh:mm 형식)
    List<String> showArriveTimeList = showArriveInfoList.map((e) {
      String hour = e.arriveDateTime.hour < 10
          ? "0${e.arriveDateTime.hour}"
          : "${e.arriveDateTime.hour}";
      String minute = e.arriveDateTime.minute < 10
          ? "0${e.arriveDateTime.minute}"
          : "${e.arriveDateTime.minute}";
      return "$hour:$minute";
    }).toList();

    if (!showArriveTimeList.contains(_selectedTime)) {
      _selectedTime = showArriveTimeList[0];
    }

    return Padding(
      padding: EdgeInsets.only(left: deviceWidth * 0.02),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: const TextStyle(
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
    // 현재 출발지, 현재 categoryTime, 오늘 날짜인 문서만 필터링
    List<TaxiScreenPostModel> postList = await TaxiScreenPostModel
        .getAllPostByCollectionAndDateTime(
        collectionName, _selectedTime!, DateTime.now());

    List<TaxiScreenPostModel> visiblePosts = postList
        .where((post) => post.visible ?? false) // visible 필드가 null인 경우를 대비
        .toList();

    return _buildPosts(context, visiblePosts, collectionName);
  }

  Future<Widget> _buildPosts(BuildContext context, List<TaxiScreenPostModel> postList, String collectionName) async {
    // 도착정보가 없을 시
    if (_isExistingArrivalInfo == false) {
      return Container();
    }
    // 선택한 시간의 등록된 게시물이 없을 시
    if (postList.isEmpty) {
      return const Center(
        child: Text("게시물을 등록해주세요!"),
      );
    }
    // 모든 작성자 정보를 읽어오기
    List<TaxiScreenPostModel> sortedPostList = postList;
    sortedPostList.sort((a, b) => b.createdTime.compareTo(a.createdTime));
    List<String> userIdList = sortedPostList.map((e) => e.writerId).toList();
    List<TaxiScreenUserModel> writerList = await TaxiScreenUserModel
        .getUserList(userIdList);

    return Expanded(
      child: ListView.separated(
        itemCount: sortedPostList.length,
        itemBuilder: (context, int index) {
          double imageSize = deviceWidth * 0.3;
          int minutesAgo = DateTime.now().difference(sortedPostList[index].createdTime).inMinutes;
          String timeText = minutesAgo == 0 ? "방금 전" : "$minutesAgo분 전";
          return sortedPostList[index].visible
              ? GestureDetector(
            onTap: () async {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      PostDetailsScreen(
                        writer: writerList[index],
                        post: sortedPostList[index],
                        collectionName:
                        converter[_selectedStartInfo]!,
                      )
              ));
              final FirebaseFirestore firestore =
                  FirebaseFirestore.instance;
              QuerySnapshot querySnapshot = await firestore
                  .collection(converter[_selectedStartInfo]!)
                  .where('categoryTime', isEqualTo: _selectedTime)
                  .where('writerId', isEqualTo: writerList[index].userId)
                  .get();
              for (var doc in querySnapshot.docs) {
                await firestore
                    .collection(converter[_selectedStartInfo]!)
                    .doc(doc.id)
                    .update({'viewCount': FieldValue.increment(1)});
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: sortedPostList[index].imageUrl.isEmpty
                        ? Image.asset(
                      'assets/images/default_avatar.png',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      sortedPostList[index].imageUrl,
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
                          sortedPostList[index].title,
                          style: TextStyle(fontSize: deviceFontSize * 1.2),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 5), // 제목과 작성자 정보 사이 간격 추가
                        Text(
                          "${writerList[index].nickname} (${writerList[index]
                              .gender})",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          timeText,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 5), // 작성자 정보와 참여 인원 사이 간격 추가
                        Text(
                          "${sortedPostList[index].memberList.length + 1}/4",
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
                                  Icons.comment_outlined, color: Colors.grey),
                            ),
                            Text(
                                " ${sortedPostList[index].commentList.length}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              : Container();
        },
        separatorBuilder: (BuildContext context, int index) {
          return sortedPostList[index].visible ? const Divider() : Container();
        },
      ),
    );
  }
}