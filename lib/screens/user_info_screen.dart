// User Information Screen
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class UserInfoScreen extends StatelessWidget {
  final User user;

  const UserInfoScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            user.kakaoAccount?.profile?.profileImageUrl != null
                ? Image.network(user.kakaoAccount!.profile!.profileImageUrl!)
                : Icon(Icons.account_circle, size: 100),
            SizedBox(height: 20),
            Text(
                'Nickname: ${user.kakaoAccount?.profile?.nickname ?? "Unavailable"}'),
            SizedBox(height: 10),
            Text('Email: ${user.kakaoAccount?.email ?? "Unavailable"}'),
          ],
        ),
      ),
    );
  }
}
