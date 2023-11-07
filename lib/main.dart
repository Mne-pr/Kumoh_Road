import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kumoh_road/samples/kakao_login.dart';
import 'package:kumoh_road/samples/main_view_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  KakaoSdk.init(nativeAppKey: 'c7b475e5111b80916e28e5e364d626311');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final viewModel = MainViewModel(KakaoLogin());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 기존 이미지 표시 조건
            if (viewModel.user?.kakaoAccount?.profile?.profileImageUrl != null
                && viewModel.user!.kakaoAccount!.profile!.profileImageUrl!.isNotEmpty)
              Image.network(viewModel.user!.kakaoAccount!.profile!.profileImageUrl!),

            Text(
              '${viewModel.isLogined}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            // 카카오 로그인 이미지 버튼
            InkWell(
              onTap: () async {
                await viewModel.login();
                setState(() {});
              },
              child: Image.asset('assets/images/kakao_login_medium_wide.png'),
            ),
          ],
        ),
      ),
    );
  }
}

