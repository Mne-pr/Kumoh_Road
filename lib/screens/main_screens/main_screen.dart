import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumoh_road/models/main_screen_button_model.dart';
import 'package:kumoh_road/screens/main_screens/weather_screen.dart';
import '../../models/announcement_model.dart';
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
  bool announcementIsExpanded = false;
  bool trainPostsIsExpanded = false;
  bool busPostsIsExpanded = false;
  bool schoolPostsIsExpanded = false;
  List<MainScreenButtonModel> items = [];

// 사용자 상호작용 버튼을 만드는 메서드
  Widget _buildUserInteractionButton(MainScreenButtonModel model) {
    return ElevatedButton.icon(
      icon: Icon(model.icon, size: 24, color: model.color),
      label: Text(model.title, style: const TextStyle(color: Colors.black)),
      onPressed: () => model.onTap(),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white, // 텍스트 및 아이콘 색상
        elevation: 3, // 그림자 깊이
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(fontSize: 12), // 텍스트 크기 조정
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
              '구미역 - 참여를 기다리는 합승',
              Icons.train,
              trainPostsIsExpanded,
                  () => setState(() => trainPostsIsExpanded = !trainPostsIsExpanded)
          ),
          buildRideSharingSection(
              'express_bus_posts',
              '구미종합버스터미널 - 참여를 기다리는 합승',
              Icons.directions_bus,
              busPostsIsExpanded,
                  () => setState(() => busPostsIsExpanded = !busPostsIsExpanded)
          ),
          buildRideSharingSection(
              'school_posts',
              '국립금오공과대학교 - 참여를 기다리는 합승',
              Icons.school,
              schoolPostsIsExpanded,
                  () => setState(() => schoolPostsIsExpanded = !schoolPostsIsExpanded)
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
    return Container(
      margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      padding:
          const EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0, bottom: 3.0),
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
              Row(
                children: [
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        announcementIsExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        key: ValueKey<bool>(announcementIsExpanded),
                        size: 30, // 화살표 크기 조절
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        announcementIsExpanded =
                            !announcementIsExpanded; // 상태 토글
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          buildAnnouncements(),
        ],
      ),
    );
  }

  Widget buildAnnouncements() {
    return StreamBuilder<QuerySnapshot>(
      // 쿼리 리미트 변경
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('date', descending: true)
          .limit(announcementIsExpanded ? 10 : 3) // 상태에 따라 리미트 변경
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
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
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
                      maxLines: 1, // 텍스트를 한 줄로 제한
                      overflow: TextOverflow.ellipsis, // 넘치는 텍스트를 말줄임표로 처리
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
    return Container(
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(collectionName)
                //.where('createdTime', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now())) // Todo UI 구현 이후 추가 예정
                .orderBy('createdTime', descending: true)
                .limit(isExpanded ? 20 : 3)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // 중첩 스크롤 방지
                children: snapshot.data!.docs.map((doc) {
                  TaxiScreenPostModel postInfo = TaxiScreenPostModel(
                      writerId: doc['writer'],
                      title: doc['title'],
                      content: doc['content'],
                      createdTime: (doc['createdTime'] as Timestamp).toDate(),
                      viewCount: doc['viewCount'],
                      imageUrl: doc['image'],
                      membersIdList: doc['members'],
                      commentList: doc['commentList']
                  );
                  String formattedTime = DateFormat('HH:mm').format(postInfo.createdTime); // 생성 시간 포맷

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
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 6.0),
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
                            formattedTime,
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
          ),
        ],
      ),
    );
  }
}
