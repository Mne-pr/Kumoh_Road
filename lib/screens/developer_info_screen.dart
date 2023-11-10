import 'package:flutter/material.dart';
import '../utilities/url_launcher_util.dart'; // launchURL 함수 import

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개발자 정보', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: ListView(
        children: const [
          DeveloperInfo(
            name: '송제용',
            role: '프로젝트 리더 및 개발자',
            responsibilities: [
              '프로젝트 일정 및 GitHub 프로젝트 관리',
              '로그인 및 메인 화면 시스템 구현',
              '프로필 조회 기능 구현',
              '송금 기능 구현',
            ],
            githubUrl: 'https://github.com/joon6093',
          ),
          DeveloperInfo(
            name: '권태현',
            role: '대중교통 정보 시스템 개발자',
            responsibilities: [
              '택시 인원 모집 기능 구현',
              '프로젝트 문서화 및 관리를 위한 노션 플랫폼 운영 및 유지보수',
            ],
            githubUrl: 'https://github.com/xogus0226',
          ),
          DeveloperInfo(
            name: '손현락',
            role: '시내버스 정보 시스템 개발자',
            responsibilities: [
              '버스 정보 공유 기능 개발',
              '학교 이메일을 이용한 인증 기능 개발',
            ],
            githubUrl: 'https://github.com/Mne-pr',
          ),
          DeveloperInfo(
            name: '배건애',
            role: '자전거 경로 탐색 시스템 개발자',
            responsibilities: [
              '자전거 경로 기능 구현',
              '사용자 피드백 수집 및 반영',
            ],
            githubUrl: 'https://github.com/TankyBae',
          ),
        ],
      ),
    );
  }
}

class DeveloperInfo extends StatelessWidget {
  final String name;
  final String role;
  final List<String> responsibilities;
  final String githubUrl;

  const DeveloperInfo({
    Key? key,
    required this.name,
    required this.role,
    required this.responsibilities,
    required this.githubUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(role, style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            ...responsibilities.map((responsibility) => Text('• $responsibility')).toList(),
            const SizedBox(height: 10),
            InkWell(
              child: const Text('GitHub 프로필', style: TextStyle(color: Colors.blue)),
              onTap: () => launchURL(githubUrl),
            ),
          ],
        ),
      ),
    );
  }
}
