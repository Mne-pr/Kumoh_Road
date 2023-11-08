import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLogin {
  bool isLogined = false;
  User? user;

  Future<bool> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      user = await UserApi.instance.me();
      isLogined = true;
      return true;
    } catch (e) {
      print('로그인 실패 또는 유저 정보 가져오기 실패: $e');
      isLogined = false;
      return false;
    }
  }
}
