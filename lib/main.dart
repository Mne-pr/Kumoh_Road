import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kumoh_road/providers/user_providers.dart';
import 'package:kumoh_road/screens/launch_screens/intro_screen.dart';
import 'package:kumoh_road/screens/main_screens/main_screen.dart';
import 'package:kumoh_road/utilities/material_color_utile.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  KakaoSdk.init(nativeAppKey: 'c7b475e5111b80916e28e5e364d62631');

  await NaverMapSdk.instance.initialize(
      clientId: 't2v0aiyv0u',
      onAuthFailed: (ex) {
        print("네이버맵 로그인 오류 : $ex");
      }
  );

  UserProvider userProvider = UserProvider();
  await userProvider.checkLoginStatus();

  runApp(ChangeNotifierProvider(create: (context) => userProvider, child: const KumohRoad(),
  ));
}


class KumohRoad extends StatelessWidget {
  const KumohRoad({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KumohRoad',
      theme: ThemeData(primarySwatch: createMaterialColor(const Color(0xFF3F51B5))),
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLogged) {
            if (userProvider.isSuspended) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showAccountSuspendedDialog(context, userProvider);
              });
            }
            if (userProvider.age == null || userProvider.gender == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showAdditionalInfoDialog(context, userProvider);
              });
            }
            return MainScreen();
          } else {
            return IntroScreen();
          }
        },
      ),
    );
  }

  void _showAccountSuspendedDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('계정 정지 알림'),
          content: const Text('귀하의 계정은 정지되었습니다.\n자세한 내용은 관리자에게 문의하세요.'),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                userProvider.logout(); // 로그아웃 처리
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => IntroScreen()),
                      (Route<dynamic> route) => false,
                ); // 인트로 화면으로 이동
              },
            ),
          ],
        );
      },
    );
  }

  void _showAdditionalInfoDialog(BuildContext context, UserProvider userProvider){
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
                    userProvider.updateUserInfo(age: age, gender: gender);
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => MainScreen()),
                          (Route<dynamic> route) => false,
                    ); //
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

}
