import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/user_providers.dart';
/**
 * 게시글, 댓글, 사용자 신고를 처리할 수 있도록한다.
 * 각각에 메서드에 맞게 사용한다.
 */
class ReportManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserProvider _userProvider; // UserProvider 인스턴스 추가

  ReportManager(this._userProvider);

  // 사용자 신고 메서드
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    required String category,
  }) async {
    await _reportEntity(
      entityType: 'user',
      entityId: reportedUserId,
      reporterUserId: _userProvider.id.toString(),
      reason: reason,
      category: category,
      reportedUserId: reportedUserId, // 신고된 사용자 ID
    );
  }

  // 게시글 신고 메서드
  Future<void> reportPost({
    required String postId,
    required String reason,
    required String category,
    required String reportedUserId,
  }) async {
    await _reportEntity(
      entityType: 'post',
      entityId: postId,
      reporterUserId: _userProvider.id.toString(),
      reason: reason,
      category: category,
      reportedUserId: reportedUserId, // 게시글 작성자 ID
    );
  }

  // 게시글 댓글 신고 메서드
  Future<void> reportPostComment({
    required String postCommentId,
    required String reason,
    required String category,
    required String reportedUserId,
  }) async {
    await _reportEntity(
      entityType: 'postComment',
      entityId: postCommentId,
      reporterUserId: _userProvider.id.toString(),
      reason: reason,
      category: category,
      reportedUserId: reportedUserId, // 댓글 작성자 ID
    );
  }

  // 댓글 신고 메서드
  Future<void> reportComment({
    required String commentId,
    required String reason,
    required String category,
    required String reportedUserId,
  }) async {
    await _reportEntity(
      entityType: 'comment',
      entityId: commentId,
      reporterUserId: _userProvider.id.toString(),
      reason: reason,
      category: category,
      reportedUserId: reportedUserId, // 댓글 작성자 ID
    );
  }

  Future<void> _reportEntity({
    required String entityType,
    required String entityId,
    required String reporterUserId,
    required String reason,
    required String category,
    required String reportedUserId,
  }) async {
    try {
      // Firestore에 신고 기록 저장
      DocumentReference reportDoc = _firestore.collection('reports').doc();
      await reportDoc.set({
        'entityType': entityType,
        'entityId': entityId,
        'reason': reason,
        'category': category,
        'createdTime': FieldValue.serverTimestamp(),
        'reportedUserId': reportedUserId,   // 신고된 유저 ID
        'reporterUserId': reporterUserId,  //신고한 유저 ID
        'isHandledByAdmin': false,
      });
      // 신고 카운트 증가
      int newReportCount = _userProvider.reportCount + 1;
      await _userProvider.updateUserInfo(reportCount: newReportCount);

      // 신고 대상 사용자의 매너 온도 감소
      await _decreaseUserMannerTemperature(reportedUserId);
    } catch (e) {
      print('Error reporting $entityType: $e');
      // 여기에 예외 처리 로직
    }
  }

  Future<void> _decreaseUserMannerTemperature(String reportedUserId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(reportedUserId);
    var userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      var data = userSnapshot.data() as Map<String, dynamic>;
      double currentTemperature = data['mannerTemperature']?.toDouble() ?? 36.5;
      double newTemperature = currentTemperature - 0.1;

      // 소수점 첫째 자리까지만 나타내기
      String formattedTemperature = newTemperature.toStringAsFixed(1);

      await userDoc.update({'mannerTemperature': double.parse(formattedTemperature)});
    }
  }


  // 특정 엔티티 유형에 대한 내 신고 가져오기 메서드
  Future<List<Map<String, dynamic>>> fetchMyReports() async {
    try {
      // 'reports' 컬렉션에서 reporterUserId가 현재 로그인한 사용자 ID와 일치하고,
      // createdTime으로 내림차순 정렬된 문서를 조회
      var reportsSnapshot = await _firestore
          .collection('reports')
          .where('reporterUserId', isEqualTo: _userProvider.id.toString())
          .orderBy('createdTime', descending: true)
          .get();

      return reportsSnapshot.docs.map((doc) => {
        'id': doc.id, // Firestore 문서 ID
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error fetching reports for user ${_userProvider.id.toString()}: $e');
      return [];
    }
  }
}
