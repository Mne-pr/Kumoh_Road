import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoLoginProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isLogged => _user != null;

  Future<void> login() async {
    bool isInstalled = await isKakaoTalkInstalled();
    try {
      if (isInstalled) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }
      _user = await UserApi.instance.me();
      print('사용자 정보 가져오기 성공: $_user');

      List<String> scopes = [];
      if (_user?.kakaoAccount?.ageRangeNeedsAgreement == true) {
        scopes.add("age_range");
      }
      if (_user?.kakaoAccount?.genderNeedsAgreement == true) {
        scopes.add("gender");
      }

      if (scopes.isNotEmpty) {
        try {
          await UserApi.instance.loginWithNewScopes(scopes);
          _user = await UserApi.instance.me(); // 사용자 정보 재요청
        } catch (error) {
          print('추가 동의 요청 실패: $error');
        }
      }
    } catch (error) {
      print('로그인 실패 또는 사용자 정보 가져오기 실패: $error');
      _user = null;
    } finally {
      notifyListeners();
    }
  }
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      print('로그아웃 성공, SDK에서 토큰 삭제');
    } catch (error) {
      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
    } finally {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
      print('연결 끊기 성공, SDK에서 토큰 삭제');
    } catch (error) {
      print('연결 끊기 실패 $error');
    } finally {
      _user = null;
      notifyListeners();
    }
  }
}
