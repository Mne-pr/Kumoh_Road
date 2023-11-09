import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../providers/kakao_login_providers.dart';
import 'main_screen.dart';

class KakaoLoginPage extends StatefulWidget {
  const KakaoLoginPage({super.key});

  @override
  _KakaoLoginPageState createState() => _KakaoLoginPageState();
}

class _KakaoLoginPageState extends State<KakaoLoginPage> {

  void _showAdditionalInfoDialog() {
    int age = 25; // 초기 나이 설정
    String gender = '남성'; // 기본값 설정

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('추가 정보 입력'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              content: Container(
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
                      child: Container(
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<KakaoLoginProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/app_logo.png', width: 130, height: 130),
        const SizedBox(height: 24),
        const Text(
          '금오로드 시작하기',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '간편하게 로그인하고 서비스를 이용하세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () async {
            await userProvider.login();
            if (userProvider.isLogged && (userProvider.age == null || userProvider.gender == null)) {
              _showAdditionalInfoDialog(); // 나이와 성별 정보가 없는 경우에만 대화상자 표시
            } else if (userProvider.isLogged) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            } else {
              print("로그인은 성공했지만, 사용자 정보가 없는 경우");
            }
          },
          child: Image.asset('assets/images/kakao_login_medium_wide.png'),
        ),
      ],
    );
  }
}
