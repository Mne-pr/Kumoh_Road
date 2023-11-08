import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/screens/user_info_screen.dart';

import '../providers/kakao_login_providers.dart';

class KakaoLoginPage extends StatefulWidget {
  @override
  _KakaoLoginPageState createState() => _KakaoLoginPageState();
}

class _KakaoLoginPageState extends State<KakaoLoginPage> {
  final kakaoLogin = KakaoLogin();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/app_logo.png', width: 100, height: 100),
        const SizedBox(height: 24),
        Text(
          '금오로드 시작하기',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '간편하게 로그인하고 서비스를 이용하세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () async {
            try {
              await kakaoLogin.login();
              if (kakaoLogin.isLogined && kakaoLogin.user != null) {
                print('로그인 성공, 유저 데이터: ${kakaoLogin.user}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoScreen(user: kakaoLogin.user!),
                  ),
                );
              } else {
                print('로그인 성공, 유저 정보 없음');
                // 유저 정보 없음에 대한 처리
              }
            } catch (e) {
              print('로그인 또는 유저 데이터 가져오기 중 오류: $e');
              // 오류 처리
            }
          },
          child: Image.asset('assets/images/kakao_login_medium_wide.png'),
        ),
      ],
    );
  }
}