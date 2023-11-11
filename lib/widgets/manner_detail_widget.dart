import 'package:flutter/material.dart';
/**
 * 여러 화면에서 편하게 매너 상세 화면을 출력할 수 있도록 한다.
 * 매너리스트와 비매너리스트를 인자로 넘겨서 사용한다.
 */
class MannerDetailsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> mannerList;
  final List<Map<String, dynamic>> unmannerlyList;

  const MannerDetailsWidget({
    Key? key,
    required this.mannerList,
    required this.unmannerlyList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildSectionTitle('😊 받은 매너 칭찬'),
        _buildMannerList(mannerList),
        _buildSectionTitle('😡 받은 비매너'),
        _buildMannerList(unmannerlyList),
      ],
    );
  }
  List<Map<String, dynamic>> _getFilteredMannerList(
      List<Map<String, dynamic>>? manners) {
    if (manners == null) {
      return [];
    }
    return manners.where((manner) => manner['votes'] > 0).toList();
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildMannerList(List<Map<String, dynamic>> manners) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      // Prevents nested scrolling
      shrinkWrap: true,
      // Adjusts ListView size based on content
      itemCount: manners.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(manners[index]['content']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 20),
              SizedBox(width: 5),
              Text('${manners[index]['votes']}'),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
}