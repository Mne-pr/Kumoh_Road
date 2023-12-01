import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/main_screen_button_model.dart';
import 'package:kumoh_road/screens/main_screens/weather_screen.dart';
import '../../models/announcement_model.dart';
import '../../models/bus_station_model.dart';
import '../../models/taxi_screen_post_model.dart';
import '../../models/taxi_screen_user_model.dart';
import '../../utilities/url_launcher_util.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../taxi_screens/post_details_screen.dart';
import '../user_info_screens/other_user_info_screen.dart';
import 'announcement_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool announcementIsExpanded = true;
  bool trainPostsIsExpanded = true;
  bool busPostsIsExpanded = true;
  bool schoolPostsIsExpanded = true;
  bool busListIsExpanded = true;
  List<MainScreenButtonModel> items = [];

// 사용자 상호작용 버튼을 만드는 메서드
  Widget _buildUserInteractionButton(MainScreenButtonModel model) {
    return ElevatedButton.icon(
      icon: Icon(model.icon, size: 24, color: model.color),
      label: Text(model.title, style: const TextStyle(color: Colors.black)),
      onPressed: () => model.onTap(),
      style: ElevatedButton.styleFrom(
        primary: Colors.white, // 배경색
        onPrimary: Colors.black, // 전경색(텍스트 및 아이콘 색상)
        elevation: 3, // 그림자 깊이
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
          side: BorderSide(color: Colors.grey), // 테두리 추가
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(fontSize: 12), // 텍스트 크기 조정
        shadowColor: Colors.grey.withOpacity(0.5), // 그림자 색상
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    items = [
      MainScreenButtonModel(
        icon: Icons.school,
        title: '학교 홈페이지',
        color: Colors.green,
        url: 'https://www.kumoh.ac.kr/ko/index.do',
        onTap: () => launchURL('https://www.kumoh.ac.kr/ko/index.do'),
      ),
      MainScreenButtonModel(
        icon: Icons.email,
        title: '웹 메일',
        color: Colors.blue,
        url: 'https://mail.kumoh.ac.kr/account/login.do',
        onTap: () => launchURL('https://mail.kumoh.ac.kr/account/login.do'),
      ),
      MainScreenButtonModel(
        icon: Icons.computer,
        title: '강의지원시스템',
        color: Colors.yellow,
        url: 'https://elearning.kumoh.ac.kr/',
        onTap: () => launchURL('https://elearning.kumoh.ac.kr/'),
      ),
      MainScreenButtonModel(
        icon: Icons.code,
        title: '깃허브',
        color: Colors.brown,
        url: 'https://github.com/joon6093/Kumoh_Road',
        onTap: () => launchURL('https://github.com/joon6093/Kumoh_Road'),
      ),
      MainScreenButtonModel(
        icon: Icons.wb_sunny,
        title: '날씨 정보',
        color: Colors.red,
        url: '',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WeatherScreen()),
          );
        },
      ),
      MainScreenButtonModel(
        icon: Icons.chat,
        title: '인공지능 채팅',
        color: Colors.blueGrey,
        url: '',
        onTap: () {
          // AI Chat 화면으로 이동
        },
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildUserInteractionButtons(context),
          buildAnnouncementsSection(),
          buildRideSharingSection(
              'train_posts',
              '구미역에서 모집중인 합승',
              Icons.train,
              trainPostsIsExpanded,
                  () => setState(() => trainPostsIsExpanded = !trainPostsIsExpanded)
          ),
          buildRideSharingSection(
              'express_bus_posts',
              '터미널에서 모집중인 합승',
              Icons.directions_bus,
              busPostsIsExpanded,
                  () => setState(() => busPostsIsExpanded = !busPostsIsExpanded)
          ),
          buildRideSharingSection(
              'school_posts',
              '금오공과대학교에서 모집중인 합승',
              Icons.school,
              schoolPostsIsExpanded,
                  () => setState(() => schoolPostsIsExpanded = !schoolPostsIsExpanded)
          ),
          buildBusSection(
              'bus_station_info',
              '댓글을 기다리는 버스', // 섹션 제목
              Icons.comment_outlined, // 버스 아이콘
              busListIsExpanded, // 확장 상태를 추적하는 변수
                  () => setState(() => busListIsExpanded = !busListIsExpanded) // 확장 상태 토글
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('송제용 유저 프로필 보기(테스트 용 예시)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const OtherUserProfileScreen(userId: '3153999885'),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 0,
      ),
    );
  }

  Widget _buildUserInteractionButtons(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 60.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(top:10, bottom: 3,left: index == 0 ? 10 : 0, right: 10),
                child: _buildUserInteractionButton(items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildAnnouncementsSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      padding: const EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0, bottom: 3.0),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.announcement, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '공지사항',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    announcementIsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    key: ValueKey<bool>(announcementIsExpanded),
                    size: 24,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    announcementIsExpanded = !announcementIsExpanded;
                  });
                },
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: buildAnnouncements(),
            crossFadeState: announcementIsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 500),
          ),
        ],
      ),
    );
  }

  Widget buildAnnouncements() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('date', descending: true)
          .limit(4)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('오류');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.requireData;

        return SingleChildScrollView(
          child: Column(
            children: List.generate(data.size, (index) {
              var announcementData = data.docs[index];
              var announcement = Announcement.fromMap(announcementData.id,
                  announcementData.data() as Map<String, dynamic>);
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AnnouncementDetailScreen(announcement: announcement),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[400],
                      ),
                      child: Text(
                        announcement.type,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      announcement.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget buildRideSharingSection(String collectionName, String title, IconData iconData, bool isExpanded, VoidCallback toggleExpansion) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500), // 속도를 빠르게 조정
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      padding: const EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0, bottom: 3.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(iconData, size: 24),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 15)),
                ],
              ),
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    key: ValueKey<bool>(isExpanded),
                    size: 24,
                  ),
                ),
                onPressed: toggleExpansion,
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0), // 축소된 상태일 때의 위젯
            secondChild: buildPostsList(collectionName), // 확장된 상태일 때의 위젯
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 500),
          ),
        ],
      ),
    );
  }

  Widget buildPostsList(String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
      //.where('categoryTime', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now())) // Todo UI 구현 이후 추가 예정
          .orderBy('categoryTime', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // 중첩 스크롤 방지
          children: snapshot.data!.docs.map((doc) {
            TaxiScreenPostModel postInfo = TaxiScreenPostModel(
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
            );

            return InkWell(
              onTap: () async {
                TaxiScreenUserModel writerInfo = await TaxiScreenUserModel.getUserById(postInfo.writerId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailsScreen(
                      writerUserInfo: writerInfo, // writerInfo 전달
                      postInfo: postInfo, // postInfo 전달
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.all(2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[400],
                    ),
                    child: Text(
                      postInfo.categoryTime,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    doc['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildBusSection(String collectionName, String title, IconData iconData, bool isExpanded, VoidCallback toggleExpansion) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      padding: const EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0, bottom: 3.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(iconData, size: 24),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 15)),
                ],
              ),
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    key: ValueKey<bool>(isExpanded),
                    size: 24,
                  ),
                ),
                onPressed: toggleExpansion,
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: buildBusList(collectionName),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 500),
          ),
        ],
      ),
    );
  }

  Widget buildBusList(String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy('arrtime', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // 중첩 스크롤 방지
          children: snapshot.data!.docs.map((doc) {
            Bus busInfo = Bus.fromJson(doc.data() as Map<String, dynamic>);
            return InkWell(
              onTap: () {
                // 버스 상세 정보 보기 동작
              },
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.all(2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[400],
                    ),
                    child: Text(
                      busInfo.arrtime.toString(), // 정류장 이름
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    busInfo.routeno, // 버스 번호
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 여기에 추가적인 버스 정보를 표시할 수 있습니다.
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
