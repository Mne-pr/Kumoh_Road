import 'package:flutter/material.dart';
import 'package:kumoh_road/providers/kakao_login_providers.dart';
import 'package:kumoh_road/screens/privacy_policy_screen.dart';
import 'package:kumoh_road/screens/terms_service_screen.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'developer_info_screen.dart';
import 'faq_screen.dart';
import 'oss_licenses_screen.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<KakaoLoginProvider>(context);
    void _showAdditionalInfoDialog() {
      int age = userProvider.age ?? 25; // 사용자의 현재 나이를 가져오거나 기본값 설정
      String gender = userProvider.gender ?? '남성'; // 사용자의 현재 성별을 가져오거나 기본값 설정
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('추가 정보 수정'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "이 단계는 향후 비즈니스 검증 절차를 완료한 후\n 카카오 로그인을 통해 자동으로 수집될 예정입니다.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text('나이'),
                      Center(
                        child: SizedBox(
                          height: 100,
                          child: NumberPicker(
                            value: age,
                            minValue: 19,
                            maxValue: 30,
                            onChanged: (value) => setState(() => age = value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('성별'),
                      Center(
                        child: SizedBox(
                          width: 150,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: gender,
                            items: <String>['남성', '여성'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                gender = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('저장'),
                    onPressed: () async {
                      await Provider.of<KakaoLoginProvider>(context, listen: false)
                          .updateUserInfo(age: age, gender: gender);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }
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
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text('로그아웃'),
              onPressed: () {
                handleLogout();
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
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('탈퇴하기'),
              onPressed: () {
                handleUnlink();
              },
            ),
          ],
        ),
      );
    }
    double mannerTemperature = userProvider.mannerTemperature;
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
        title: const Text('나의 정보', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () => _showAdditionalInfoDialog(), // 설정 아이콘 클릭 시 대화상자 표시
          ),
        ],
        centerTitle: false, // Aligns the title to the left
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: userProvider.isLogged && userProvider.user?.kakaoAccount?.profile?.profileImageUrl != null
                          ? NetworkImage(userProvider.user!.kakaoAccount!.profile!.profileImageUrl!)
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      radius: 30,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.user?.kakaoAccount?.profile?.nickname ?? "Unavailable",
                            style: const TextStyle(fontSize: 20),
                          ),
                          // 나이와 성별 정보 표시
                          Text(
                            "${userProvider.age ?? '알 수 없음'}세 (${userProvider.gender ?? '성별 미정'})",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('금오온도란?'),
                              content: const Text('금오온도는 사용자의 활동에 기반한 평판 점수입니다. \n긍정적인 활동으로 온도가 상승하며, 부정적인 행동으로 하락합니다.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('닫기'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            '금오온도',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$mannerTemperature°C $temperatureEmoji',
                            style: TextStyle(
                              fontSize: 16,
                              color: temperatureColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: mannerTemperature / 100,
                              backgroundColor: Colors.grey[300],
                              color: temperatureColor,
                              minHeight: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 리뷰 목록 버튼
                      TextButton(
                        onPressed: () {
                          // TODO: Add navigation to the review list screen
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.star_border, color: Colors.black),
                            SizedBox(height: 10), // 버튼과 텍스트 사이 간격 추가
                            Text('내 리뷰 목록'),
                          ],
                        ),
                      ),
                      // QR 코드 등록 버튼
                      TextButton(
                        onPressed: () {
                          // TODO: Add navigation to the QR code registration screen
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.qr_code_scanner),
                            SizedBox(height: 10), // 버튼과 텍스트 사이 간격 추가
                            Text('QR 코드 등록'),
                          ],
                        ),
                      ),
                      // 학생 인증 버튼
                      TextButton(
                        onPressed: () {
                          // TODO: Add navigation to the student verification screen
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.school),
                            SizedBox(height: 10), // 버튼과 텍스트 사이 간격 추가
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
          ExpansionTile(
            leading: const Icon(Icons.info_outline, color: Colors.black),
            title: const Text('이용안내'),
            children: [
              ListTile(
                leading: const Icon(Icons.question_answer, color: Colors.black),
                title: const Text('자주묻는 질문'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.black),
                title: const Text('서비스 이용 약관'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.policy, color: Colors.black),
                title: const Text('개인정보 처리방침'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.black),
                title: const Text('오픈소스 라이센스'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OssLicensesScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.black),
                title: const Text('개발자 정보'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeveloperInfoScreen()),
                  );
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