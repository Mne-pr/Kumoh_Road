import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/user_info_screen.dart';
import 'package:provider/provider.dart';

import '../providers/kakao_login_providers.dart';
import 'main_screen.dart';

class KakaoLoginPage extends StatefulWidget {
  const KakaoLoginPage({super.key});

  @override
  _KakaoLoginPageState createState() => _KakaoLoginPageState();
}

class _KakaoLoginPageState extends State<KakaoLoginPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<KakaoLoginProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/app_logo.png', width: 100, height: 100),
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
            try {
              await userProvider.login(); // Use the user provider to log in
              if (userProvider.isLogged) {
                print('로그인 성공, 유저 데이터: ${userProvider.user}');
                Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(),
                  ),
                );
              } else {
                print('로그인 성공, 유저 정보 없음');
              }
            } catch (e) {
              print('로그인 또는 유저 데이터 가져오기 중 오류: $e');
            }
          },
          child: Image.asset('assets/images/kakao_login_medium_wide.png'),
        ),
      ],
    );
  }
}