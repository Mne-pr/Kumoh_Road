import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kumoh_road/models/taxi_screen_post_model.dart';
import 'package:kumoh_road/models/taxi_screen_user_model.dart';
import 'package:kumoh_road/screens/taxi_screens/post_create_screen.dart';
import 'package:kumoh_road/screens/taxi_screens/post_details_screen.dart';
import 'package:logger/logger.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../widgets/loding_indicator_widget.dart';

class TaxiScreen extends StatefulWidget {
  const TaxiScreen({Key? key}) : super(key: key);

  @override
  _TaxiScreenState createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  final List<String> _startList = ['금오공과대학교', '구미종합터미널', '구미역'];
  String _selectedStartInfo = "금오공과대학교";
  bool _isSelectedKumohUniversity = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStartInfo(context),
                if (!_isSelectedKumohUniversity) _buildArrivalInfo(context)
              ],
            ),
            const Divider(),
            FutureBuilder(
              future: _fetchAndBuildPosts(context),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: LoadingIndicatorWidget());
                else if (snapshot.hasError) {
                  final log = Logger(printer: PrettyPrinter());
                  log.i("${snapshot.error}");
                  log.i("${snapshot.stackTrace}");
                  return Center(child: Text("게시글을 불러올 수 없습니다."));
                } else if (snapshot.hasData) {
                  return snapshot.data!;
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(selectedIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PostCreateScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStartInfo(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            value: _selectedStartInfo,
            onChanged: (String? newValue) {
              setState(() {
                _selectedStartInfo = newValue ?? "invalid source";
                _isSelectedKumohUniversity = newValue == "금오공과대학교";
              });
            },
            items: _startList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future getBusAPI(Uri url) async {
    final http.Response res = await http.get(url);
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return print(res.statusCode);
    }
  }

  Future getTrainAPI(Uri url) async {
    final http.Response res = await http.get(url);
    if (res.statusCode == 200) {
      return res.body;
    } else {
      return print(res.statusCode);
    }
  }

  Widget _buildArrivalInfo(BuildContext context) {
    // TODO: API에서 정보 얻어오기
    List<String> arrivalTimeList = [
      "08:00",
      "09:00",
      "10:00",
      "11:00",
      "12:00"
    ];
    String? _selectedArrivalTime = arrivalTimeList[0];

    if (arrivalTimeList.isEmpty) {
      return Text("No arrival times available");
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        value: _selectedArrivalTime,
        onChanged: (String? newValue) {
          setState(() {
            _selectedArrivalTime = newValue;
          });
        },
        items: arrivalTimeList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text('$value 도착'),
          );
        }).toList(),
      ),
    );
  }

  Future<Widget> _fetchAndBuildPosts(BuildContext context) async {
    String collectionName = "";
    if (_selectedStartInfo == "금오공과대학교")
      collectionName = "school_posts";
    else if (_selectedStartInfo == "구미종합터미널")
      collectionName = "express_bus_posts";
    else if (_selectedStartInfo == "구미역") collectionName = "train_posts";

    // 해당 출발지의 모든 게시글 읽어오기
    List<TaxiScreenPostModel> postList =
        await TaxiScreenPostModel.getAllPostsByCollectionName(collectionName);

    return _buildPosts(context, postList);
  }

  Future<Widget> _buildPosts(
      BuildContext context, List<TaxiScreenPostModel> postList) async {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultFontSize = Theme.of(context).textTheme.bodyLarge!.fontSize!;
    double imageHeight = screenHeight * 0.2;
    double contentFontSize = defaultFontSize;
    EdgeInsets leftPadding = EdgeInsets.only(left: screenWidth * 0.01);

    // 모든 게시물의 모든 작성자 정보를 읽어오기
    List<TaxiScreenUserModel> writerInfoList = [];
    for (var post in postList) {
      TaxiScreenUserModel writerInfo =
          await TaxiScreenUserModel.getUserById(post.writerId);
      writerInfoList.add(writerInfo);
    }

    List<InkWell> postWidgetList = [];

    for (int i = 0; i < postList.length; i++) {
      InkWell post = InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PostDetailsScreen(
                  writerUserInfo: writerInfoList[i], postInfo: postList[i])));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          height: imageHeight,
          child: Row(
            children: [
              Image.network(
                postList[i].imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/default_avatar.png',
                      fit: BoxFit.cover);
                },
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.03),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(postList[i].title,
                          style: TextStyle(
                            fontSize: defaultFontSize * 1.1,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis),
                      Row(children: [
                        const Icon(Icons.account_circle, color: Colors.grey),
                        Padding(
                            padding: leftPadding,
                            child: Text(
                                '${writerInfoList[i].nickname}(${writerInfoList[i].gender})',
                                style: TextStyle(
                                    fontSize: contentFontSize,
                                    color: Colors.grey))),
                      ]),
                      Row(children: [
                        const Icon(Icons.timer_sharp, color: Colors.grey),
                        Padding(
                          padding: leftPadding,
                          child: Text(
                              '${postList[i].createdTime.hour}시 ${postList[i].createdTime.minute}분',
                              style: TextStyle(
                                  fontSize: contentFontSize,
                                  color: Colors.grey)
                          ),
                        ),
                      ]),
                      Row(children: [
                        const Icon(Icons.people_sharp, color: Colors.grey),
                        Padding(
                          padding: leftPadding,
                          child: Text(
                              "${postList[i].membersIdList.length + 1}/4명",
                              style: TextStyle(
                                  fontSize: contentFontSize,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                        ),
                      ]),
                      Row(children: [
                        const Icon(Icons.rate_review_sharp, color: Colors.grey),
                        Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child:
                                Text(
                                    "${postList[i].commentList.length}개",
                                  style: TextStyle(
                                      fontSize: contentFontSize,
                                      color: Colors.grey
                                  ),
                                ),
                        ),
                      ])
                ],),
              ),
            ],
          ),
        ),
      );
      postWidgetList.add(post);
    }

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: postWidgetList,
      ),
    );
  }
}
