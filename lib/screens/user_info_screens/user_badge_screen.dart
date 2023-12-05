import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../models/badge_model.dart';
import '../../providers/user_providers.dart';

class BadgeScreen extends StatefulWidget {
  @override
  _BadgeScreenState createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkForBadgeAcquisition());
  }

  void checkForBadgeAcquisition() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userBadgeList = userProvider.badgeList;

    // 각 배지에 대한 조건 검사 및 토스트 메시지 표시
    checkAndNotify(userProvider.postCount, 0, "택시 리더", userBadgeList);
    checkAndNotify(userProvider.commentCount, 1, "정보 공유자", userBadgeList);
    checkAndNotify(1, 2, "초보 사용자", userBadgeList, false); // 초보 사용자는 조건 없음
    checkAndNotify(userProvider.reportCount, 3, "금오로드 보안관", userBadgeList);
    checkAndNotify(userProvider.postCommentCount, 4, "합승의 시작", userBadgeList);
    // 새로운 배지에 대한 조건 검사
    checkAndNotify(userProvider.postCount, 5, "택시 운전자", userBadgeList, true, 10);
    checkAndNotify(userProvider.commentCount, 6, "버스회사 아들", userBadgeList, true, 10);
    checkAndNotify(userProvider.postCommentCount, 7, "합승 전문가", userBadgeList, true, 10);
    checkAndNotify(userProvider.reportCount, 8, "친절한 이웃", userBadgeList, true, 10);
  }

  void checkAndNotify(int count, int index, String badgeName, List<int> badgeList, [bool checkCount = true, int threshold = 5]) {
    if (badgeList.length > index && badgeList[index] == 0 && (!checkCount || count >= threshold)) {
      showToast("$badgeName 배지를 획득할 수 있습니다.\n터치하여 배지를 받으세요!");
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      fontSize: 16.0,
      textColor: Colors.black,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  final List<UserBadge> badges = [
    UserBadge(
      name: "택시 리더",
      description: "택시 인원 모집 게시판을 5회 이상 개설한 사용자에게 부여",
      icon: Icons.directions_car,
    ),
    UserBadge(
      name: "정보 공유자",
      description: "댓글을 이용해 버스 정보를 5회 이상 공유한 사용자에게 부여",
      icon: Icons.share,
    ),
    UserBadge(
      name: "초보 사용자",
      description: "애플리케이션에 처음 가입한 사용자에게 부여",
      icon: Icons.star_border,
    ),
    UserBadge(
      name: "금오로드 보안관",
      description: "신고 행위를 5번 이상 한 사람에게 부여",
      icon: Icons.security,
    ),
    UserBadge(
      name: "합승의 시작",
      description: "택시 게시글에 대한 댓글 참여를 5회 이상 한 사용자에게 부여",
      icon: Icons.comment,
    ),
    UserBadge(
      name: "택시 운전자",
      description: "택시 인원 모집 게시판을 10회 이상 개설한 사용자에게 부여",
      icon: Icons.group,
    ),
    UserBadge(
      name: "버스회사 아들",
      description: "댓글을 이용해 버스 정보를 10회 이상 공유한 사용자에게 부여",
      icon: Icons.lightbulb,
    ),
    UserBadge(
      name: "합승 전문가",
      description: "택시 게시글에 대한 댓글 참여를 10회 이상 한 사용자에게 부여",
      icon: Icons.directions_car_filled,
    ),
    UserBadge(
      name: "친절한 이웃",
      description: "신고 행위를 10번 이상 한 사람에게 부여",
      icon: Icons.handshake,
    ),
    UserBadge(
      name: "별밤 여행자",
      description: "밤 10시 이후에 택시 합승을 5회 이상 주선한 사용자에게 부여",
      icon: Icons.nights_stay,
    ),
    UserBadge(
      name: "맛집 탐험가",
      description: "다양한 지역의 음식점에 대한 리뷰를 5회 이상 작성한 사용자에게 부여",
      icon: Icons.restaurant_menu,
    ),
    UserBadge(
      name: "조조 할인 마스터",
      description: "아침 6시 이전에 택시를 이용한 사용자에게 부여",
      icon: Icons.wb_sunny,
    ),
    UserBadge(
      name: "친환경 전도사",
      description: "일주일 동안 대중교통만 이용한 사용자에게 부여",
      icon: Icons.eco,
    ),
    UserBadge(
      name: "금오새",
      description: "앱 활동을 열심히 한 사용자에게 직접 부여",
      icon: Icons.psychology,
    ),
    UserBadge(
      name: "도전 정신",
      description: "한 달 동안 매일 다른 도전 과제를 완수한 사용자에게 부여",
      icon: Icons.sports_handball,
    ),
    UserBadge(
      name: "우주 탐사자",
      description: "앱의 모든 기능을 사용해 본 사용자에게 부여",
      icon: Icons.explore,
    ),
    UserBadge(
      name: "행복 전파자",
      description: "다른 사용자들에게 긍정적인 메시지를 10회 이상 보낸 사용자에게 부여",
      icon: Icons.sentiment_satisfied,
    ),
    UserBadge(
      name: "커피 후원자",
      description: "고생하는 개발자에게 커피를 사주신 사용자에게 부여",
      icon: Icons.sentiment_satisfied,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userBadgeList = userProvider.badgeList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('획득 배지', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),

        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final isBadgeOwned = userBadgeList.length > index && userBadgeList[index] == 1;

          return GestureDetector(
            onTap: () {
              if (!isBadgeOwned) {
                checkAndAwardBadge(badge, index, userProvider);
              } else {
                showToast(badge.description); // 이미 획득한 배지의 설명 표시
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: isBadgeOwned ? Colors.blue : Colors.grey,
                  child: Icon(
                    isBadgeOwned ? badge.icon : Icons.help_outline,
                    size: 40.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  badge.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void checkAndAwardBadge(UserBadge badge, int index, UserProvider userProvider) {
    int count = 0;
    bool shouldAward = false;

    switch (badge.name) {
      case "택시 리더":
        count = userProvider.postCount;
        shouldAward = count >= 5;
        break;
      case "정보 공유자":
        count = userProvider.commentCount;
        shouldAward = count >= 5;
        break;
      case "초보 사용자":
        shouldAward = true; // 조건 없음
        break;
      case "금오로드 보안관":
        count = userProvider.reportCount;
        shouldAward = count >= 5;
        break;
      case "합승의 시작":
        count = userProvider.postCommentCount;
        shouldAward = count >= 5;
        break;
      case "택시 운전자":
        count = userProvider.postCount;
        shouldAward = count >= 10;
        break;
      case "버스회사 아들":
        count = userProvider.commentCount;
        shouldAward = count >= 10;
        break;
      case "합승 전문가":
        count = userProvider.postCommentCount;
        shouldAward = count >= 10;
        break;
      case "친절한 이웃":
        count = userProvider.reportCount;
        shouldAward = count >= 10;
        break;
    }

    if (shouldAward) {
      awardBadge(index, badge.name);
    }
  }

  void awardBadge(int index, String badgeName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var updatedBadgeList = List<int>.from(userProvider.badgeList);
    updatedBadgeList[index] = 1;
    await userProvider.updateUserInfo(badgeList: updatedBadgeList);
    showToast('축하합니다!\n"$badgeName" 배지를 획득하셨습니다!');
  }
}
