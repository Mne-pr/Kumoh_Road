class TaxiScreenPostModel{
  final String writerId;
  final String title;
  final String content;
  final DateTime createdTime;
  final int viewCount;
  final List<String> commentsList;
  final String imageUrl;
  final List<String> membersIdList;

  TaxiScreenPostModel({
    required this.writerId,
    required this.title,
    required this.content,
    required this.createdTime,
    required this.viewCount,
    required this.commentsList,
    required this.imageUrl,
    required this.membersIdList,
  });
}