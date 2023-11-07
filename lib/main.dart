import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kumoh Road',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IntroScreen(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  final List<Widget> _pages = [
    GuidePage(
      icon: Icons.local_taxi,
      title: '택시 요금을 줄여보세요',
      description: '공유하면 학생들이 모여 택시비를 줄일 수 있어요!',
    ),
    GuidePage(
      icon: Icons.directions_bus,
      title: '정확한 버스 정보를 받아보세요',
      description: '실시간 버스 정보를 이용하세요!',
    ),
    GuidePage(
      icon: Icons.directions_bike,
      title: '경로정보를 이용하세요',
      description: '구미 대중교통에 스트레스 받지마시고 마음편하게 학교로 가세요',
    ),
    KakaoLoginPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: _pages,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: WormEffect(),
              onDotClicked: (index) => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuidePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const GuidePage({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class KakaoLoginPage extends StatelessWidget {
  final viewModel = MainViewModel(KakaoLogin());
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/app_logo.png', width: 100, height: 100),
        const SizedBox(height: 24),
        Text(
          '카카오 계정으로 로그인',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '간편하게 로그인하고 서비스를 이용하세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () async {
            await viewModel.login();
          },
          child: Image.asset('assets/images/kakao_login_medium_wide.png'),
        ),
      ],
    );
  }
}
