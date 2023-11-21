import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../../providers/kakao_login_providers.dart';
import '../../widgets/loding_indicator_widget.dart';
import '../main_screens/main_screen.dart';

class KakaoLoginPage extends StatefulWidget {
  const KakaoLoginPage({super.key});

  @override
  _KakaoLoginPageState createState() => _KakaoLoginPageState();
}

class _KakaoLoginPageState extends State<KakaoLoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<KakaoLoginProvider>(context, listen: false);
    await userProvider.login();

    if (userProvider.isLogged) {
      if (userProvider.age == null || userProvider.gender == null) {
        _showAdditionalInfoDialog();
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      print("로그인은 성공했지만, 사용자 정보가 없는 경우");
    }
    setState(() => _isLoading = false);
  }

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
    return Scaffold(
      body: Center(
        child: _isLoading
            ? LoadingIndicatorWidget()
            : Column(
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
              onTap: _login,
              child: Image.asset('assets/images/kakao_login_medium_wide.png'),
            ),
          ],
        ),
      ),
    );
  }
}
