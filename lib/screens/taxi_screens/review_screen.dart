import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

Logger log = Logger(printer: PrettyPrinter());

const List<String> _mannerCategories = [
  '목적지 변경에 유연하게 대응해줬어요.',
  '합승 비용을 정확히 계산하고 공정하게 나눠냈어요.',
  '다른 인원의 합승 요청에 신속하게 응답했어요.',
  '개인 사진으로 위치 인증을 해서 신뢰가 갔어요.'
];
const List<String> _unmannerCategories = [
  '게시된 합승 시간보다 많이 늦게 도착했어요.',
  '비용을 더 많이 내게 하려는 태도를 보였어요.',
  '위치 인증 없이 불분명한 장소를 제시했어요.',
  '합승 중 타인에 대한 불편한 발언을 했어요.'
];
const Map<String, double> mapFeedbackToTemperature = {
  '별로에요': -0.100000,
  '좋아요!': 0.1000000,
  '최고에요!': 0.2000000
};
const Map<String, String> mapFeedbackToFieldName = {
  '별로에요': 'unmannerList',
  '좋아요!': 'mannerList',
  '최고에요!': 'mannerList'
};
class ReviewScreen extends StatefulWidget {
  final String writerId;
  final String writerName;

  const ReviewScreen({
    Key? key,
    required this.writerId,
    required this.writerName
  }) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _feedback = "좋아요";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('합승 리뷰 작성하기'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildGuideMsgSection(),
              _buildEmogiSection(),
              _buildCategorySection(context),
            ],
          ),
        )
    );
  }

  Widget _buildGuideMsgSection() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "'${widget.writerName}'\n방장님과의 택시 합승 어떠셨나요?",
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmogiSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
              child: emotionItem("별로에요")
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            child: emotionItem("좋아요!"),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            child: emotionItem("최고에요!"),
          ),
        ],
      ),
    );
  }

  Widget emotionItem(String msg) {
    late Icon face;
    Color color = Colors.grey; // 기본 색상 설정

    if (msg == '별로에요') {
      face = const Icon(Icons.sentiment_very_dissatisfied);
      if (_feedback == '별로에요') {
        color = Colors.red; // 선택된 경우 색상 변경
      }
    } else if (msg == "좋아요!") {
      face = const Icon(Icons.sentiment_satisfied);
      if (_feedback == '좋아요!') {
        color = Colors.amber; // 선택된 경우 색상 변경
      }
    } else if (msg == "최고에요!") {
      face = const Icon(Icons.sentiment_very_satisfied);
      if (_feedback == '최고에요!') {
        color = Colors.green; // 선택된 경우 색상 변경
      }
    }

    return InkWell(
      onTap: (){
        setState(() {
          _feedback = msg;
        });
      },
      splashColor: Colors.grey,
      child: Container(
        child: Column(
          children: [
            Transform.scale(
              scale: 3,
              child: Icon(
                face.icon,
                color: color, // 적용된 색상
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(msg),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    if(_feedback == "별로에요"){
      return categorySection(context, _unmannerCategories);
    }
    else{
      return categorySection(context, _mannerCategories);
    }
  }

  Widget categorySection(BuildContext context, List<String> categoryList){
    return Expanded(
      child: ListView(
        children: [
          const Divider(),
          ListTile(
            onTap: () { submitReview(context, category: categoryList[0]);},
            title: Text(categoryList[0]),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            onTap: () { submitReview(context, category: categoryList[1]);},
            title: Text(categoryList[1]),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            onTap: () { submitReview(context, category: categoryList[2]);},
            title: Text(categoryList[2]),
            trailing: const Icon(Icons.chevron_right),
          ),
          ListTile(
            onTap: () { submitReview(context, category: categoryList[3]);},
            title: Text(categoryList[3]),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Future<void> submitReview(BuildContext context, {required String category}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference colRef = firestore.collection("users");
    QuerySnapshot querySnapshot = await colRef.where("nickname", isEqualTo: widget.writerName).get();
    // 현재 게시글 문서 read
    DocumentReference? newDoc;
    for(var doc in querySnapshot.docs){
      if(doc.id == widget.writerId){
        newDoc = colRef.doc(doc.id);
      }
    }
    // 예외 처리
    if(newDoc == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 쓰기 작업 실패")),
      );
      log.e("해당 게시글 문서 read 실패");
      return;
    }

    final docSnap = await newDoc.get();

    List<dynamic>? modifyingMannerList = docSnap[mapFeedbackToFieldName[_feedback]!];
    // 예외 처리
    if(modifyingMannerList == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 쓰기 작업 실패")),
      );
      log.e("해당 게시글 문서 read 실패");
      return;
    }
    //votes, temperature 증가
    for(var e in modifyingMannerList){
      if(e['content'] == category){
        e['votes']++;
      }
    }
    await newDoc.update({
      mapFeedbackToFieldName[_feedback]! : modifyingMannerList,
      // 소수점 1자리 수를 더하면 계산오차가 생겨서(eg. 0.2를 더했는데 결과는 0.19999999999를 더한 값으로 DB에 저장됨)
      'mannerTemperature': roundToSecondDecimal(docSnap['mannerTemperature'] + mapFeedbackToTemperature[_feedback]),
    });

    Navigator.pop(context);
    Navigator.pop(context);
  }

  double roundToSecondDecimal(double value) {
    return (value * 10).roundToDouble() / 10;
  }

}
