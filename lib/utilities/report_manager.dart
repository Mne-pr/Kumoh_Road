import 'package:cloud_firestore/cloud_firestore.dart';
/**
 * 게시글, 댓글, 사용자 신고를 처리할 수 있도록한다.
 * 각각에 메서드에 맞게 사용한다.
 */
class ReportManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _reporterUserId;

  ReportManager(this._reporterUserId);

  // 사용자 신고 메서드
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
  }) async {
    await _reportEntity(
      entityType: 'user',
      entityId: reportedUserId,
      reporterUserId: _reporterUserId,
      reason: reason,
    );
  }

  // 게시글 신고 메서드
  Future<void> reportPost({
    required String postId,
    required String reason,
  }) async {
    await _reportEntity(
      entityType: 'post',
      entityId: postId,
      reporterUserId: _reporterUserId,
      reason: reason,
    );
  }

  // 댓글 신고 메서드
  Future<void> reportComment({
    required String commentId,
    required String reason,
  }) async {
    await _reportEntity(
      entityType: 'comment',
      entityId: commentId,
      reporterUserId: _reporterUserId,
      reason: reason,
    );
  }

  // 모든 엔티티에 대한 일반적인 신고 처리 메서드
  Future<void> _reportEntity({
    required String entityType,
    required String entityId,
    required String reporterUserId,
    required String reason,
  }) async {
    try {
      DocumentReference reportDoc = _firestore.collection('reports').doc();
      await reportDoc.set({
        'entityType': entityType,
        'entityId': entityId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'reporterUserId': reporterUserId,
        'isHandledByAdmin': false,
      });
    } catch (e) {
      print('Error reporting $entityType: $e');
      // 예외 처리
    }
  }

  // 특정 엔티티 유형에 대한 신고 가져오기 메서드 후에 관리자 모드 구현에서 사용
  Future<List<Map<String, dynamic>>> fetchReportsForEntityType(String entityType) async {
    try {
      var reportsSnapshot = await _firestore
          .collection('reports')
          .where('entityType', isEqualTo: entityType)
          .get();
      return reportsSnapshot.docs.map((doc) => {
        'id': doc.id, 
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error fetching reports for $entityType: $e');
      // 예외 처리
      return [];
    }
  }

  // 특정 엔티티 유형에 대한 내 신고 가져오기 메서드
  Future<List<Map<String, dynamic>>> fetchMyReports() async {
    try {
      // 'reports' 컬렉션에서 reporterUserId가 현재 로그인한 사용자 ID와 일치하는 문서를 조회
      var reportsSnapshot = await _firestore
          .collection('reports')
          .where('reporterUserId', isEqualTo: _reporterUserId)
          .get();

      return reportsSnapshot.docs.map((doc) => {
        'id': doc.id, // Firestore 문서 ID
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error fetching reports for user $_reporterUserId: $e');
      // 예외 처리
      return [];
    }
  }
}
