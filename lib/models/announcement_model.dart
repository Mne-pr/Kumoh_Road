class Announcement {
  String type;
  String title;
  String content;
  DateTime date;

  Announcement({required this.type, required this.title, required this.content, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title' : title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      type: map['type'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
    );
  }
}
