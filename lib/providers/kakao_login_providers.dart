import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoLoginProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isLogged => _user != null;

  Future<void> login() async {
    // 카카오톡 실행 가능 여부 확인
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        _user = await UserApi.instance.me();
        notifyListeners();
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          _user = await UserApi.instance.me();
          notifyListeners();
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
          _user = null;
          notifyListeners();
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
        _user = await UserApi.instance.me();
        notifyListeners();
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
        _user = null;
        notifyListeners();
      }
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
