import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kumoh_road/samples/kakao_login.dart';

class MainViewModel {
  final KakaoLogin _kakaoLogin;
  bool isLogined = false;
  User? user;
  MainViewModel(this._kakaoLogin);
  Future login() async {
    isLogined = await _kakaoLogin.login();
    if (isLogined) {
      user = await UserApi.instance.me();
    }
  }
}