import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoLoginProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLogged => _user != null;

  Future<void> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      _user = await UserApi.instance.me();
      notifyListeners();
    } catch (e) {
      print('로그인 실패 또는 유저 정보 가져오기 실패: $e');
      _user = null;
    }
  }
}
