import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/screens/admin_screens/admin_main_screen.dart';
import 'package:kumoh_road/screens/admin_screens/admin_taxi_manage_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../providers/user_providers.dart';
import '../../widgets/report_count_widget.dart';
import '../main_screens/main_screen.dart';
import '../user_info_screens/other_user_info_screen.dart';
import '../../widgets/manner_detail_widget.dart';

Logger log = Logger(printer: PrettyPrinter());
UserProvider? currUser;

late double deviceWidth;
late double deviceHeight;
late double deviceFontSize;
late Color mainColor;

class AdminPostDetailScreen extends StatefulWidget {
  final TaxiScreenPostModel postModel;
  final String entityId;
  final TaxiScreenUserModel writerModel;
  final QuerySnapshot documents;

  const AdminPostDetailScreen({super.key, required this.postModel, required this.entityId, required this.writerModel, required this.documents});

  @override
  State<AdminPostDetailScreen> createState() => _AdminPostDetailScreenState();
}

class _AdminPostDetailScreenState extends State<AdminPostDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    currUser = Provider.of<UserProvider>(context, listen: false);
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    deviceFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    mainColor = Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _mainScreen(),
          _bottomSection()
        ],
      ),
    );
  }

  Widget _mainScreen(){
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          imageSection(),
          const SizedBox(height: 4),
          userInfoSection(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostContentSection(context),
                const Divider(),
                _buildReviewSection(context),
              ],
            ),
          ),
          const Divider(),
          _buildReportContentSection(),
          SizedBox(
            height: deviceHeight * 0.3,
          ),
        ],
      ),
    );
  }

  Widget imageSection() {
    return Stack(
      children: [
        _buildImageSection(context),
        Positioned(
          left: 0,
          right: 0,
          top: deviceHeight * 0.04,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 왼쪽 아이콘들
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_outlined,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AdminMainScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return imageWidget(widget.postModel.imageUrl, context);
  }

  Widget imageWidget(String imageUrl, BuildContext context) {
    return imageUrl.isEmpty
        ? Image.asset(
      'assets/images/default_avatar.png',
      width: deviceWidth,
      height: deviceWidth * 0.8,
      fit: BoxFit.cover,
    )
        : Image.network(
      widget.postModel.imageUrl,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return child;
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      width: deviceWidth,
      height: deviceWidth * 0.8,
      fit: BoxFit.cover,
    );
  }


  Widget userInfoSection(){
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          if (currUser!.id.toString() != widget.postModel.writerId) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OtherUserProfileScreen(userId: widget.postModel.writerId),
            ));
          }
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(widget.writerModel.profileImageUrl),
          radius: 28,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  widget.writerModel.nickname,
                  style: const TextStyle(
                      fontSize: 16),
                ),
              ],
            ),
          ),
          Text(
            '${widget.writerModel.mannerTemperature}°C',
            style: TextStyle(
              fontSize: 16,
              color: _getTemperatureColor(
                  widget.writerModel.mannerTemperature),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          _getTemperatureEmoji(widget.writerModel.mannerTemperature),
        ],
      ),
      subtitle: Row(
        children: [
          Text('${widget.writerModel.age}세 (${widget.writerModel.gender})'),
          const Spacer(),
          _buildMannerBar(widget.writerModel.mannerTemperature),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature >= 37.5) {
      return Colors.red;
    } else if (temperature >= 36.5) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Widget _getTemperatureEmoji(double temperature) {
    String emoji;
    if (temperature >= 37.5) {
      emoji = '🥵';
    } else if (temperature >= 36.5) {
      emoji = '😊';
    } else {
      emoji = '😨';
    }
    return Text(emoji);
  }

  Widget _buildMannerBar(double temperature) {
    return Container(
      width: 100, // 매너 막대 너비 고정
      height: 8, // 매너 막대 높이
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: temperature / 100,
          backgroundColor: Colors.grey[300],
          color: _getTemperatureColor(temperature),
          minHeight: 6,
        ),
      ),
    );
  }


  Widget _buildPostContentSection(BuildContext context) {
    int minutesAgo =
        DateTime.now().difference(widget.postModel.createdTime).inMinutes;
    String timeText = minutesAgo > 0 ? "$minutesAgo분전" : "방금전";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.postModel.title,
            style: TextStyle(
              fontSize: deviceFontSize * 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4), // 제목과 시간 사이의 간격 조정
          Text(
            timeText,
            style:
            TextStyle(color: Colors.grey, fontSize: deviceFontSize * 0.9),
          ),
          const SizedBox(height: 8), // 시간과 내용 사이의 간격 조정
          Text(
            widget.postModel.content,
            style: TextStyle(fontSize: deviceFontSize),
          ),
          const SizedBox(height: 4), // 내용과 조회수 사이의 간격 조정
          Text(
            "조회 ${widget.postModel.viewCount}회",
            style:
            TextStyle(color: Colors.grey, fontSize: deviceFontSize * 0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    double defaultFontSize = deviceFontSize;

    List<Map<String, dynamic>> filteredMannerList = widget.writerModel.mannerList!
        .where((review) => review["votes"] > 0)
        .toList();
    List<Map<String, dynamic>> filteredUnmannerList = widget
        .writerModel.unmannerList!
        .where((review) => review["votes"] > 0)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "${widget.writerModel.nickname}님의 택시 합승 리뷰",
              style: TextStyle(
                  fontSize: defaultFontSize * 1.1, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right, size: 24),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => MannerDetailsWidget(
                  mannerList: filteredMannerList,
                  unmannerlyList: filteredUnmannerList,
                ),
              );
            },
          ),
          ...filteredMannerList
              .take(2)
              .map((review) => _buildReviewListItem(review, true))
              .toList(),
          ...filteredUnmannerList
              .take(2)
              .map((review) => _buildReviewListItem(review, false))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReviewListItem(Map<String, dynamic> review, bool isManner) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(review['content']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isManner ? Icons.thumb_up_alt : Icons.thumb_down_alt,
              color: isManner ? Colors.green : Colors.red, size: 20),
          const SizedBox(width: 4),
          Text('${review['votes']}'),
        ],
      ),
    );
  }

  Widget _buildReportContentSection() {
    Map<String, List<String>> categoryToDetails = {};

    for (var doc in widget.documents.docs) {
      String category = doc['category'];
      String detail = "${doc['reason']} \n${doc['createdTime'].toDate().toString()}";

      if (!categoryToDetails.containsKey(category)) {
        categoryToDetails[category] = [];
      }
      categoryToDetails[category]!.add(detail);
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: categoryToDetails.entries.map((entry) {
        return _buildReportCategoryItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildReportCategoryItem(String category, List<String> details) {
    return ExpansionTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category),
          const SizedBox(width: 8),
          ReportCountWidget(details.length),
        ],
      ),
      children: details.map((detail) {
        var parts = detail.split('\n');
        String reason = '신고내용: ${parts[0]}';
        String date = '신고시간: ${parts[1]}';

        return ListTile(
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: reason,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: '\n$date',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bottomSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 55,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton("무시", handleIgnore, Colors.grey, Icons.delete),
            const SizedBox(width: 10),
            _buildActionButton("블라인드", handleBlind, const Color(0xFF3F51B5), Icons.visibility_off),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, Function onPressed, Color color, IconData icon) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () async {
          await onPressed();
          Navigator.of(context).pop();
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }



  Future<void> handleIgnore() async {
    var reports = await firestore.collection('reports')
        .where('entityId', isEqualTo: widget.entityId)
        .get();

    for (var report in reports.docs) {
      await report.reference.update({'isHandledByAdmin': true});
    }
  }


  Future<void> handleBlind() async {
    var reports = await firestore.collection('reports')
        .where('entityId', isEqualTo: widget.entityId)
        .get();

    for (var report in reports.docs) {
      await report.reference.update({'isHandledByAdmin': true});
    }

    var colId = widget.entityId.split(":")[0];
    var docId = widget.entityId.split(":")[1];
    var modifyingDoc = firestore.collection(colId).doc(docId);
    await modifyingDoc.update({'visible': false});
  }

}
