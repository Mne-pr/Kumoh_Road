class Announcement {
  String id;
  String type;
  String title;
  String content;
  DateTime date;
  int views; // 조회수 필드 추가

  Announcement({
    this.id = '',
    required this.type,
    required this.title,
    required this.content,
    required this.date,
    required this.views,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'date': date,
      'views': views,
    };
  }

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      type: map['type'],
      title: map['title'],
      content: map['content'],
      date: map['date'].toDate(),
      views: map['views'] ?? 0, // null일 경우 0으로 설정
    );
  }
}
