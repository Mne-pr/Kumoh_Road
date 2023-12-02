import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/badge_model.dart';

class OtherUserBadgeScreen extends StatelessWidget {
  final List<int> badgeList; // 다른 사용자의 배지 리스트

  const OtherUserBadgeScreen({Key? key, required this.badgeList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('배지 정보', style: TextStyle(color: Colors.black)),
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
          final isBadgeOwned = badgeList.length > index && badgeList[index] == 1;

          return Column(
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
          );
        },
      ),
    );
  }
}
