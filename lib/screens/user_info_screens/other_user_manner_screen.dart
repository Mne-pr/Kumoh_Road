import 'package:flutter/material.dart';
import '../../widgets/manner_detail_widget.dart';

class OtherUserMannerScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mannerList;
  final List<Map<String, dynamic>> unmannerlyList;

  const OtherUserMannerScreen({
    Key? key,
    required this.mannerList,
    required this.unmannerlyList,
  }) : super(key: key);

  List<Map<String, dynamic>> _getFilteredMannerList(List<Map<String, dynamic>>? manners) {
    if (manners == null) {
      return [];
    }
    return manners.where((manner) => manner['votes'] > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMannerList = _getFilteredMannerList(mannerList);
    final filteredUnmannerlyList = _getFilteredMannerList(unmannerlyList);

    return Scaffold(
      appBar: AppBar(
        title: const Text('매너 상세', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: MannerDetailsWidget(
        mannerList: filteredMannerList,
        unmannerlyList: filteredUnmannerlyList,
      ),
    );
  }
}
