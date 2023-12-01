import 'package:flutter/material.dart';
class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 묻는 질문', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          FAQItem(
              question: '금오로드 앱의 주요 기능은 무엇인가요?',
              answer: '금오로드는 학생들의 이동을 편리하게 돕는 다양한 기능을 제공합니다. 주요 기능으로는 실시간 합승 정보, 버스 정보 제공, 자전거 경로 안내 등이 있습니다.'
          ),
          FAQItem(
              question: '카카오 로그인은 어떻게 이루어지나요?',
              answer: '카카오 계정을 통해 간편하게 로그인할 수 있으며, 로그인 시 사용자 정보를 안전하게 관리합니다.'
          ),
          FAQItem(
              question: '날씨 정보는 어떻게 확인할 수 있나요?',
              answer: '홈 화면에서 날씨 정보 버튼을 클릭하면 현재 위치의 날씨 정보를 확인할 수 있습니다. 이 정보는 이동수단 선택에 도움을 줍니다.'
          ),
          FAQItem(
              question: '자전거 경로는 어떻게 확인할 수 있나요?',
              answer: '자전거 경로 화면에서는 현재 위치에서 목적지까지의 최적 경로를 제공합니다. 주행 거리와 예상 도착 시간도 함께 표시됩니다.'
          ),
          FAQItem(
              question: '택시 인원 모집 게시글은 어떻게 작성하나요?',
              answer: '택시 인원 모집 화면에서 새 게시글을 작성할 수 있습니다. 출발 위치, 목적지, 출발 시간 등의 정보를 선택하고 게시글을 작성하면 됩니다..'
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({Key? key, required this.question, required this.answer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
