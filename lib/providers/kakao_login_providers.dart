import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoLoginProvider with ChangeNotifier {
  User? _user;
  int? _age;
  String? _gender;
  double? _mannerTemperature;
  List<Map<String, dynamic>>? _mannerList;
  List<Map<String, dynamic>>? _unmannerList;
  String? _qrCodeUrl;

  User? get user => _user;
  bool get isLogged => _user != null;
  int? get age => _age;
  String? get gender => _gender;
  double? get mannerTemperature => _mannerTemperature;
  List<Map<String, dynamic>>? get mannerList => _mannerList;
  List<Map<String, dynamic>>? get unmannerList => _unmannerList;
  String? get qrCodeUrl => _qrCodeUrl;

  Future<void> login() async {
    bool isInstalled = await isKakaoTalkInstalled();
    try {
      if (isInstalled) {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } else {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      }
      _user = await UserApi.instance.me();
      if (_user != null) {
        await _saveOrUpdateUserInfo(_user!);
      }
      print('사용자 정보 가져오기 성공: $_user');
    } catch (error) {
      print('로그인 실패 또는 사용자 정보 가져오기 실패: $error');
      _user = null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _saveOrUpdateUserInfo(User user) async {
    var userDocument = FirebaseFirestore.instance.collection('users').doc(user.id.toString());
    var snapshot = await userDocument.get();

    // 사용자의 추가 정보
    String email = user.kakaoAccount?.email ?? '이메일 없음';
    String profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl ?? '이미지 URL 없음';
    String nickname = user.kakaoAccount?.profile?.nickname ?? '닉네임 없음';

    if (snapshot.exists) {
      var data = snapshot.data();
      _age = data?['age'];
      _gender = data?['gender'];
      _mannerTemperature = data?['mannerTemperature'];
      _mannerList = List<Map<String, dynamic>>.from(data?['mannerList'] ?? []);
      _unmannerList = List<Map<String, dynamic>>.from(data?['unmannerList'] ?? []);
      _qrCodeUrl = data?['qrCodeUrl'];
      // Firestore 문서 업데이트 (변경된 정보만 업데이트)
      Map<String, dynamic> updates = {};
      if (data?['email'] != email) updates['email'] = email;
      if (data?['profileImageUrl'] != profileImageUrl) updates['profileImageUrl'] = profileImageUrl;
      if (data?['nickname'] != nickname) updates['nickname'] = nickname;

      if (updates.isNotEmpty) {
        await userDocument.update(updates);
      }
    } else {
      _mannerTemperature = 36.5;
      _mannerList = [
        {'content': '목적지 변경에 유연하게 대응해줬어요.', 'votes': 0},
        {'content': '합승 비용을 정확히 계산하고 공정하게 나눠냈어요.', 'votes': 0},
        {'content': '다른 인원의 합승 요청에 신속하게 응답했어요.', 'votes': 0},
        {'content': '개인 사진으로 위치 인증을 해서 신뢰가 갔어요.', 'votes': 0},
      ];
      _unmannerList = [
        {'content': '게시된 합승 시간보다 많이 늦게 도착했어요.', 'votes': 0},
        {'content': '비용을 더 많이 내게 하려는 태도를 보였어요.', 'votes': 0},
        {'content': '위치 인증 없이 불분명한 장소를 제시했어요.', 'votes': 0},
        {'content': '합승 중 타인에 대한 불편한 발언을 했어요.', 'votes': 0},
      ];
      _qrCodeUrl = null;
      await userDocument.set({
        'email': email,
        'profileImageUrl': profileImageUrl,
        'nickname': nickname,
        'age': _age,
        'gender': _gender,
        'mannerTemperature': 36.5,
        'mannerList': _mannerList,
        'unmannerList': _unmannerList,
        'qrCodeUrl': _qrCodeUrl,
      });
    }
    notifyListeners();
  }


  Future<void> updateUserInfo({int? age, String? gender}) async {
    if (_user != null) {
      var userDocument = FirebaseFirestore.instance.collection('users').doc(_user!.id.toString());
      var updateData = <String, dynamic>{};
      if (age != null) {
        _age = age;
        updateData['age'] = age;
      }
      if (gender != null) {
        _gender = gender;
        updateData['gender'] = gender;
      }
      if (updateData.isNotEmpty) {
        await userDocument.update(updateData);
      }
    }
  }

  Future<void> updateMannerTemperature(double temperature) async {
    if (_user != null) {
      _mannerTemperature = temperature;
      var userDocument = FirebaseFirestore.instance.collection('users').doc(_user!.id.toString());
      await userDocument.update({'mannerTemperature': temperature});
      notifyListeners();
    }
  }

  Future<void> saveQRCodeUrl(String url) async {
    if (_user != null) {
      var userDocument = FirebaseFirestore.instance.collection('users').doc(_user!.id.toString());
      _qrCodeUrl = url;
      await userDocument.update({'qrCodeUrl': url});
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
      _gender = null;
      _age = null;
      _mannerTemperature = -1;
      notifyListeners();
    }
  }

  Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
      print('연결 끊기 성공, SDK에서 토큰 삭제');
      if (_user != null) {
        // Firestore에서 사용자 정보 삭제
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.id.toString())
            .delete();
        print('Firestore에서 사용자 정보 삭제 성공');
      }
    } catch (error) {
      print('연결 끊기 실패: $error');
    } finally {
      _user = null;
      _gender = null;
      _age = null;
      _mannerTemperature = -1;
      notifyListeners();
    }
  }

}