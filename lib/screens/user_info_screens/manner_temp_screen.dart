import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_providers.dart';
import '../../widgets/manner_detail_widget.dart';

class MannerTemperatureScreen extends StatelessWidget {
  MannerTemperatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final mannerList = _getFilteredMannerList(userProvider.mannerList);
    final unmannerlyList = _getFilteredMannerList(userProvider.unmannerList);

    return Scaffold(
      appBar: AppBar(
        title: const Text('매너 상세', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
      ),
      body: MannerDetailsWidget(
        mannerList: mannerList,
        unmannerlyList: unmannerlyList,
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredMannerList(
      List<Map<String, dynamic>>? manners) {
    if (manners == null) {
      return [];
    }
    return manners.where((manner) => manner['votes'] > 0).toList();
  }
}
