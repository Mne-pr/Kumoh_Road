import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_providers.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({super.key});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 좌측 X 버튼
            // 제목 입력란
            // 내용 입력란
            // 하단 Row(좌측 카메라 버튼, 우측 완료 버튼)
          ],
        ),
      ),
    );
  }
}
