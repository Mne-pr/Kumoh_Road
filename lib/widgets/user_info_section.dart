import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:provider/provider.dart';

import '../screens/taxi_screens/post_create_screen.dart';
import '../screens/user_info_screens/other_user_info_screen.dart';
/**
 * 여러 화면에서 편하게 사용자 정보를 보여줄 수 있도록한다.
 * 파이어베이스 또는 userProvider 모두 사용할 수 있도록 변수를 통해 받아올 수 있도록 함.
 */
class UserInfoSection extends StatefulWidget {
  final String nickname;
  final String imageUrl;
  final int age;
  final String gender;
  final double mannerTemperature;

  const UserInfoSection({
    Key? key,
    required this.nickname,
    required this.imageUrl,
    required this.age,
    required this.gender,
    required this.mannerTemperature,
  }) : super(key: key);

  @override
  _UserInfoSectionState createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends State<UserInfoSection> {
  late ImageProvider backgroundImage;

  @override
  void initState() {
    super.initState();
    backgroundImage = NetworkImage(widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    Color temperatureColor;
    String temperatureEmoji;

    if (widget.mannerTemperature >= 37.5) {
      temperatureColor = Colors.red;
      temperatureEmoji = '🥵'; // Hot face
    } else if (widget.mannerTemperature >= 36.5 && widget.mannerTemperature < 37.5) {
      temperatureColor = Colors.orange;
      temperatureEmoji = '😊'; // Smiling face
    } else {
      temperatureColor = Colors.blue;
      temperatureEmoji = '😨'; // Cold face
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  String thisPostUserId = '';
                  try {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference collection = firestore.collection('users');
                    QuerySnapshot querySnapshot = await collection
                        .where('nickname', isEqualTo: widget.nickname)
                        .get();
                    var doc = querySnapshot.docs.first;
                    thisPostUserId = doc.id;
                  } on Exception catch (e) {
                    log.e(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('해당 사용자정보 로딩 실패')),
                    );
                    return;
                  }
                  // 내 프로필 눌렀을 경우, 아무 반응 없도록
                  UserProvider currUser = Provider.of<UserProvider>(context, listen: false);
                  if(currUser.id.toString() == thisPostUserId) {
                    log.i("내 프로필 클릭함");
                    return;
                  }

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => OtherUserProfileScreen(userId: thisPostUserId),
                  ));
                },
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: backgroundImage,
                  onBackgroundImageError: (_, __) {
                    setState(() {
                      backgroundImage = const AssetImage('assets/images/default_avatar.png');
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nickname,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.age}세 (${widget.gender})",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        InkWell(
                          onTap: () => _showMannerTemperatureInfo(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                                size: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '금오온도',
                                style: TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${widget.mannerTemperature}°C $temperatureEmoji',
                style: TextStyle(
                  fontSize: 16,
                  color: temperatureColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: widget.mannerTemperature / 100,
              backgroundColor: Colors.grey[300],
              color: temperatureColor,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showMannerTemperatureInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('금오온도란?'),
          content: const Text('금오온도는 사용자의 활동에 기반한 평판 점수입니다.\n긍정적인 활동으로 온도가 상승하며, 부정적인 행동으로 하락합니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
