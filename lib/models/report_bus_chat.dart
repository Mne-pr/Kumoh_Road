import 'package:cloud_firestore/cloud_firestore.dart';

class ReportBusChatItem{
  final String chatId; // 댓글 찾을 때 사용
  final String writtenAt; // 댓글 찾을 때 사용
  final String commentString; // 출력용
  final DateTime reportedAt; // 출력?용
  final String reporter;
  final String targetId;
  late int reportCounts = 1;
  late List<String> reporters = [];

  ReportBusChatItem({
    required this.chatId,
    required this.writtenAt,
    required this.commentString,
    required this.reporter,
    required this.reportedAt,
    required this.targetId,
  });

  void addReporter(String newReporter) {
    reporters.add(newReporter);
    reportCounts += 1;
  }

  factory ReportBusChatItem.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return ReportBusChatItem(
      chatId: data['reason'],
      writtenAt: data['entityId'],
      commentString: data['category'],
      reportedAt: (data['createdTime'] as Timestamp).toDate(),
      targetId: data['reportedUserId'],
      reporter: data['reporterUserId'],
    );
  }

}
class ReportBusChatAnalyzeList{
  final List<ReportBusChatItem> list;
  ReportBusChatAnalyzeList({required this.list});

  static Future<ReportBusChatAnalyzeList> fromCollection(QuerySnapshot col) async {
    final List<ReportBusChatItem> reportList = [];

    for (var reportItem in col.docs) { // 리포트 각각의 doc들
      final item = await ReportBusChatItem.fromDocument(reportItem);
      // 일단 첫 인자는 무조건 추가
      if (reportList.isEmpty) {reportList.add(item);}

      else {
        bool dupFound = false;
        // 중복된 댓글에 대한 제보라면 제보자아이디와 카운터만 증가
        for (var report in reportList) {
          if (report.targetId == item.targetId && report.writtenAt == item.writtenAt && report.chatId == item.chatId) {
            report.addReporter(item.reporter);
            dupFound = true;
            break;
          }
        }
        // 새로운 제보면 제보리스트에 추가
        if (!dupFound) {
          reportList.add(item);
        }
      }
    }

    return ReportBusChatAnalyzeList(list: reportList);
  }
}