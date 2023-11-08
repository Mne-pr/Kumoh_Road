// User Information Screen
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/providers/kakao_login_providers.dart';
import 'package:provider/provider.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<KakaoLoginProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            userProvider.isLogged
                ? Image.network(userProvider.user?.kakaoAccount?.profile?.profileImageUrl ?? '')
                : const Icon(Icons.account_circle, size: 100),
            const SizedBox(height: 20),
            Text('Nickname: ${userProvider.user?.kakaoAccount?.profile?.nickname ?? "Unavailable"}'),
            const SizedBox(height: 10),
            Text('Email: ${userProvider.user?.kakaoAccount?.email ?? "Unavailable"}'),
          ],
        ),
      ),
    );
  }
}
