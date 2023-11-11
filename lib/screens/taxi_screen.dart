import 'package:flutter/material.dart';

import '../widgets/bottom_navigation_bar.dart';

class TaxiScreen extends StatefulWidget {
  const TaxiScreen({Key? key}) : super(key: key);

  @override
  _TaxiScreenState createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  String dropdownValue = '6:45 도착 시외버스'; // 초기 선택값, API로부터 받아올 값
  String selectedCategory = '버스'; // 상단의 선택된 버튼 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = '버스'; // 버튼 상태 업데이트
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedCategory == '버스' ? const Color(0xFF3F51B5) : Colors.transparent, // 조건부 배경색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: selectedCategory == '버스' ? const Color(0xFF3F51B5) : Colors.black12), // 조건부 테두리 색상
                    ),
                    child: Text(
                      "버스",
                      style: TextStyle(
                        color: selectedCategory == '버스' ? Colors.white : Colors.black26,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, top: 5),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedCategory = '기차'; // 버튼 상태 업데이트
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: selectedCategory == '기차' ? const Color(0xFF3F51B5) : Colors.transparent, // 조건부 배경색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: selectedCategory == '기차' ?const Color(0xFF3F51B5) : Colors.black12), // 조건부 테두리 색상
                    ),
                    child: Text(
                      "기차",
                      style: TextStyle(
                        color: selectedCategory == '기차' ? Colors.white : Colors.black26,
                      ),
                    ),
                  ),
                //TODO: 검색 버튼 만들기
                //TODO: 메뉴 버튼 만들기
                //TODO: 알림 모양 버튼 만들기
                ),
            ],),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                          // API로부터 받아온 도착 시간 데이터를 여기에 업데이트
                        });
                      },
                      items: <String>[
                        '6:45 도착 시외버스',
                        '7:00 도착 시외버스',
                        '7:15 도착 시외버스'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // TODO: 실제 DB 데이터 크기로 변경
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 6 -
                        16, // 화면 높이의 1/4에서 카드의 마진만큼 뺀 높이
                    child: Card(
                      margin: EdgeInsets.all(8), // 카드 외부 여백
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 카드 모서리 둥글게
                      ),
                      elevation: 4, // 카드 그림자 깊이
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          // 자식들이 카드 높이만큼 늘어나도록
                          children: [
                            // 왼쪽 이미지
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(10)), // 왼쪽 모서리만 둥글게
                                child: Image.network(
                                  'https://saldfjaskldfjlaks',
                                  // 실제 이미지 URL로 변경
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                    // 이미지 로드에 실패했을 때 회색 배경을 보여주는 컨테이너
                                    return Image.asset(
                                      'assets/images/default_avatar.png',
                                      // 에셋 이미지 경로
                                      width: 100,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                            // 오른쪽 정보
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10), // 내부 여백
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '터미널에서 블랙핑크 가실분', // TODO: 실제 제목 데이터로 변경
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow:
                                          TextOverflow.ellipsis, // 긴 텍스트 ... 처리
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '전지민(여) · 20분 전',
                                      // // TODO: 실제 부가 정보 데이터로 변경
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 댓글 아이콘과 숫자
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              // 좌우 여백
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.comment, color: Colors.grey),
                                  Text('1'), // 실제 댓글 수 데이터로 변경
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 게시물 추가 또는 다른 액션을 위한 핸들러
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
