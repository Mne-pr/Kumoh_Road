import 'dart:async';

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
  bool _isStudentVerified = false;
  StreamSubscription<DocumentSnapshot>? _userChangesSubscription;

  User? get user => _user;
  bool get isLogged => _user != null;
  int? get age => _age;
  String? get gender => _gender;
  double? get mannerTemperature => _mannerTemperature;
  List<Map<String, dynamic>>? get mannerList => _mannerList;
  List<Map<String, dynamic>>? get unmannerList => _unmannerList;
  String? get qrCodeUrl => _qrCodeUrl;
  bool get isStudentVerified => _isStudentVerified;

  String? getCurrentUserId() {
    return _user?.id.toString();
  }

  Future<void> login() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }
      _user = await UserApi.instance.me();
      if (_user != null) {
        await _saveOrUpdateUserInfo(_user!);
      }
    } on KakaoAuthException catch (e) {
      // 카카오 인증 관련 에러 처리
    } on Exception catch (e) {
      // 다른 유형의 에러 처리
    } finally {
      notifyListeners();
    }
  }

  // 사용자 정보 저장 또는 업데이트
  Future<void> _saveOrUpdateUserInfo(User user) async {
    // Firestore 문서 참조 생성
    var userDocument = FirebaseFirestore.instance.collection('users').doc(user.id.toString());
    var snapshot = await userDocument.get();

    // 사용자의 추가 정보
    String email = user.kakaoAccount?.email ?? '이메일 없음';
    String profileImageUrl = user.kakaoAccount?.profile?.profileImageUrl ?? '이미지 URL 없음';
    String nickname = user.kakaoAccount?.profile?.nickname ?? '닉네임 없음';

    if (snapshot.exists) {
      var data = snapshot.data();
      _updateLocalUserData(data);
      // Firestore 문서 업데이트 (변경된 정보만 업데이트)
      Map<String, dynamic> updates = {};
      if (data?['email'] != email) updates['email'] = email;
      if (data?['profileImageUrl'] != profileImageUrl) updates['profileImageUrl'] = profileImageUrl;
      if (data?['nickname'] != nickname) updates['nickname'] = nickname;
      if (updates.isNotEmpty) {
        await userDocument.update(updates);
      }
    } else {
      // 새 사용자 정보 Firestore에 저장
      await userDocument.set({
        'email': email,
        'profileImageUrl': profileImageUrl,
        'nickname': nickname,
        'age': _age,
        'gender': _gender,
        'mannerTemperature': 36.5,
        'mannerList':  [
          {'content': '목적지 변경에 유연하게 대응해줬어요.', 'votes': 0},
          {'content': '합승 비용을 정확히 계산하고 공정하게 나눠냈어요.', 'votes': 0},
          {'content': '다른 인원의 합승 요청에 신속하게 응답했어요.', 'votes': 0},
          {'content': '개인 사진으로 위치 인증을 해서 신뢰가 갔어요.', 'votes': 0},
        ],
        'unmannerList': [
          {'content': '게시된 합승 시간보다 많이 늦게 도착했어요.', 'votes': 0},
          {'content': '비용을 더 많이 내게 하려는 태도를 보였어요.', 'votes': 0},
          {'content': '위치 인증 없이 불분명한 장소를 제시했어요.', 'votes': 0},
          {'content': '합승 중 타인에 대한 불편한 발언을 했어요.', 'votes': 0},
        ],
        'qrCodeUrl': _qrCodeUrl,
        'studentVerified' : _isStudentVerified,
      });
    }
    notifyListeners();
  }

  // Firestore 데이터 변경 감지 메서드
  void startListeningToUserChanges() {
    if (_user != null && _userChangesSubscription == null) {
      _userChangesSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.id.toString())
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          var data = snapshot.data();
          _updateLocalUserData(data);
          notifyListeners();
        }
      }, onError: (error) {
        // Firestore 리스너 오류 처리
      });
    }
  }

  // 사용자 데이터 업데이트 메서드
  void _updateLocalUserData(Map<String, dynamic>? data) {
    _age = data?['age'];
    _gender = data?['gender'];
    _mannerTemperature = data?['mannerTemperature'];
    _mannerList = List<Map<String, dynamic>>.from(data?['mannerList'] ?? []);
    _unmannerList = List<Map<String, dynamic>>.from(data?['unmannerList'] ?? []);
    _qrCodeUrl = data?['qrCodeUrl'];
    _isStudentVerified = data?['isStudentVerified'] ?? false;
  }

  // 리소스 정리 메서드
  @override
  void dispose() {
    _userChangesSubscription?.cancel();
    super.dispose();
  }

  // 사용자 정보 업데이트 메서드
  Future<void> updateUserInfo({int? age, String? gender, String? email, String? profileImageUrl, String? nickname, String? url, bool? isStudentVerified}) async {
    if (_user != null) {
      var userDocument = FirebaseFirestore.instance.collection('users').doc(_user!.id.toString());
      var updateData = <String, dynamic>{};
      if (age != null) {
        updateData['age'] = age;
      }
      if (gender != null) {
        updateData['gender'] = gender;
      }
      if (email != null) {
        updateData['email'] = email;
      }
      if (profileImageUrl != null) {
        updateData['profileImageUrl'] = profileImageUrl;
      }
      if (nickname != null) {
        updateData['nickname'] = nickname;
      }
      if (url != null) {
        updateData['qrCodeUrl'] = url;
      }
      if (isStudentVerified != null) {
        updateData['isStudentVerified'] = isStudentVerified;
      }
      if (updateData.isNotEmpty) {
        await userDocument.update(updateData);
        notifyListeners();
      }
    }
  }


  // 로그아웃 메서드
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      // 로그아웃 성공, SDK에서 토큰 삭제
    } catch (error) {
      // 로그아웃 실패, SDK에서 토큰 삭제 실패 처리
    } finally {
      _resetLocalUserData();
      notifyListeners();
    }
  }

  // 연결 끊기 메서드
  Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
      // 연결 끊기 성공, SDK에서 토큰 삭제
      if (_user != null) {
        // Firestore에서 사용자 정보 삭제
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.id.toString())
            .delete();
      }
    } catch (error) {
      // 연결 끊기 실패 처리
    } finally {
      _resetLocalUserData();
      notifyListeners();
    }
  }

  // 로컬 사용자 데이터 초기화
  void _resetLocalUserData() {
    _user = null;
    _age = null;
    _gender = null;
    _mannerTemperature = null;
    _mannerList = null;
    _unmannerList = null;
    _qrCodeUrl = null;
    _isStudentVerified = false;
  }
}
