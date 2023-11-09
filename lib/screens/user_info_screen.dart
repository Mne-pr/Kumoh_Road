import 'package:flutter/material.dart';
import 'package:kumoh_road/providers/kakao_login_providers.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation_bar.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<KakaoLoginProvider>(context);

    void handleLogout() async {
      await userProvider.logout();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    void handleUnlink() async {
      await userProvider.unlink();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    void showLogoutConfirmationDialog() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('로그아웃'),
              onPressed: () {
                handleLogout();
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }

    void showUnlinkConfirmationDialog() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('회원탈퇴'),
          content: const Text('정말 탈퇴하시겠습니까?\n탈퇴 후에는 복구할 수 없습니다.'),
          actions: [
            TextButton(
              child: const Text('탈퇴하기'),
              onPressed: () {
                handleUnlink();
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Dismiss the dialog
              },
            ),
          ],
        ),
      );
    }

    const double mannerTemperature = 99.7;
    Color temperatureColor;
    String temperatureEmoji;
    if (mannerTemperature >= 37.5) {
      temperatureColor = Colors.red;
      temperatureEmoji = '🥵'; // Hot face
    } else if (mannerTemperature >= 36.5 && mannerTemperature < 37.5) {
      temperatureColor = Colors.orange;
      temperatureEmoji = '😊'; // Smiling face
    } else {
      temperatureColor = Colors.blue;
      temperatureEmoji = '😨'; // Cold face
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 정보', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false, // Aligns the title to the left
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: userProvider.isLogged && userProvider.user?.kakaoAccount?.profile?.profileImageUrl != null
                          ? NetworkImage(userProvider.user!.kakaoAccount!.profile!.profileImageUrl!)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      radius: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userProvider.user?.kakaoAccount?.profile?.nickname ?? "Unavailable",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Text(
                      '$mannerTemperature°C $temperatureEmoji',
                      style: TextStyle(
                        fontSize: 16,
                        color: temperatureColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: mannerTemperature / 100,
                      backgroundColor: Colors.grey[300],
                      color: temperatureColor,
                      minHeight: 10,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Add navigation to the review list screen
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.star_border, color: Colors.black), // Icon color
                            Text('내 리뷰 목록'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Add navigation to the QR code registration screen
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.qr_code_scanner),
                            Text('QR 코드 등록'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Add navigation to the student verification screen
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.school),
                            Text('학생 인증'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.info_outline, color: Colors.black),
            title: const Text('이용안내'),
            children: [
              ListTile(
                leading: const Icon(Icons.question_answer, color: Colors.black),
                title: const Text('자주묻는 질문'),
                onTap: () {
                  // TODO: Implement navigation to FAQ screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.black),
                title: const Text('서비스 이용 약관'),
                onTap: () => Navigator.pushNamed(context, '/terms'),
              ),
              ListTile(
                leading: const Icon(Icons.policy, color: Colors.black),
                title: const Text('개인정보 처리방침'),
                onTap: () => Navigator.pushNamed(context, '/privacy'),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.black),
                title: const Text('오픈소스 라이센스'),
                onTap: () => Navigator.pushNamed(context, '/license'),
              ),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.black),
                title: const Text('개발자 정보'),
                onTap: () {
                  // TODO: Implement navigation to Developer Information screen
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.more_horiz, color: Colors.black),
            title: const Text('기타'),
            children: [
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.black),
                title: const Text('로그아웃'),
                onTap: () {
                  showLogoutConfirmationDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.black),
                title: const Text('회원탈퇴'),
                onTap: () {
                  showUnlinkConfirmationDialog();
                },
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        selectedIndex: 4,
      ),
    );
  }
}
