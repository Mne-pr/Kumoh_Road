import 'package:flutter/material.dart';

import '../widgets/bottom_navigation_bar.dart';

class TaxiScreen extends StatefulWidget {
  const TaxiScreen({Key? key}) : super(key: key);

  @override
  _TaxiScreenState createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  String _dropdownValue = '시외버스'; // 초기 선택값, API로부터 받아올 값
  String _selectedVehicle = '버스'; // 상단의 선택된 버튼 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                _buildToggleButton(context, '버스'),
                _buildToggleButton(context, '기차'),
                //TODO: 검색 버튼 만들기
                //TODO: 메뉴 버튼 만들기
                //TODO: 알림 모양 버튼 만들기
              ],
            ),
            _buildArrivalInfoDropDownButton(context),
            _buildPosts(context),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 게시글 추가
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, String argTitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 5),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedVehicle = argTitle;
            _dropdownValue = argTitle;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: _selectedVehicle == argTitle
              ? const Color(0xFF3F51B5)
              : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          side: BorderSide(color: _selectedVehicle == argTitle
              ? const Color(0xFF3F51B5)
              : Colors.black12),
        ),
        child: Text(
          argTitle,
          style: TextStyle(
            color: _selectedVehicle == argTitle ? Colors.white : Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _buildArrivalInfoDropDownButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: DropdownButton<String>(
          style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          value: '${_dropdownValue} 정보1',
          onChanged: (String? newValue) {
            setState(() {
              _dropdownValue = newValue!;
            });
          },
          // TODO: DB의 버스 또는 기차 게시글 읽어서 넣기
          items: <String>['${_dropdownValue} 정보1', '${_dropdownValue} 정보2', '${_dropdownValue} 정보3'].map<
              DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPosts(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 10, // TODO: 실제 DB 데이터 크기로 변경
        itemBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: MediaQuery.of(context).size.height / 6 - 16, // 게시글 5개 정도만 보이도록
            child: Card(
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 게시글 이미지
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(10)), // 왼쪽 모서리만 둥글게
                        child: Image.network(
                          'https://saldfjaskldfjlaks', // TODO: 실제 이미지로 변경하기
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Image.asset(
                              'assets/images/default_avatar.png',
                              width: 100,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    // 게시글 제목 및 글쓴이 정보
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '터미널에서 블랙핑크 가실분', // TODO: 실제 제목 데이터로 변경
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '전지민(여) · 20분 전', // TODO: 실제 게시글 생성 시간으로 변경
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 게시글 댓글 아이콘과 숫자
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.comment, color: Colors.grey),
                          Text('1'), // TODO: 실제 댓글 수 데이터로 변경
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
    );
  }
}
