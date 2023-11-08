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
      try {
        user = await UserApi.instance.me();
      } catch (e) {
        print('유저 정보 가져오기 실패: $e');
        // 유저 정보를 가져오는 데 실패한 경우에 대한 처리
      }
    }
  }
}
