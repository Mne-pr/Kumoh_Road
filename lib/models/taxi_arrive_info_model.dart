import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ArriveInfo{
  late DateTime arriveDateTime;

  ArriveInfo({required this.arriveDateTime});

  ArriveInfo.fromTrainJson(Map<String, dynamic> json){
    String time = json["arrivalTime"];
    List<String> parts = time.split(":");

    DateTime now = DateTime.now();
    arriveDateTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  static List<ArriveInfo> fromBusJson(Map<String, dynamic> json){
    // 주간 도착 정보 추출하기
    String dayTimeString = json["schedule"];
    List<String> dayTimeList = dayTimeString.split(RegExp(r'[/\n(우등)]'));
    dayTimeList.removeWhere((item) => item.isEmpty);
    // 야간 도착 정보 추출하기
    String nightTimeString = json["nightSchedule"];
    List<String> nightTimeList = nightTimeString.split(RegExp(r'[/\n(우등)]'));
    nightTimeList.removeWhere((item) => item.isEmpty);

    List<ArriveInfo> result = [];
    DateTime now = DateTime.now();
    // 주간 도착 정보 추가하기
    for(String time in dayTimeList){
      List<String> parts = time.split(":");
      String hour = parts[0];
      String minute = parts[1];
      DateTime arriveTime = DateTime(now.year, now.month, now.day, int.parse(hour), int.parse(minute));
      result.add(ArriveInfo(arriveDateTime: arriveTime));
    }
    // 야간 도착 정보 추가하기
    for(String time in nightTimeList){
      List<String> parts = time.split(":");
      String hour = parts[0];
      String minute = parts[1];
      DateTime arriveTime = DateTime(now.year, now.month, now.day, int.parse(hour), int.parse(minute));
      result.add(ArriveInfo(arriveDateTime: arriveTime));
    }
    return result;
  }

  static Future<List<ArriveInfo>> fetchSchoolCreatedTime() async {
    QuerySnapshot<Map<String, dynamic>> allDocument = await FirebaseFirestore.instance.collection("school_posts").get();

    List<ArriveInfo> arriveInfoList = [];

    for (var doc in allDocument.docs) {
      // Firestore의 Timestamp를 DateTime으로 변환
      DateTime arriveDateTime = (doc.data()['createdTime'] as Timestamp).toDate();

      // ArriveInfo 객체 생성 및 리스트에 추가
      arriveInfoList.add(ArriveInfo(arriveDateTime: arriveDateTime));
    }

    return arriveInfoList;
  }

  static Future<List<ArriveInfo>> fetchTrainArriveInfoFromDb() async {
    QuerySnapshot<Map<String, dynamic>> allDocument = await FirebaseFirestore.instance.collection("train_arrival_info").get();

    List<ArriveInfo> arriveInfoList = [];

    for (var doc in allDocument.docs) {
      // Firestore의 Timestamp를 DateTime으로 변환
      DateTime arriveDateTime = (doc.data()['arriveDateTime'] as Timestamp).toDate();

      // ArriveInfo 객체 생성 및 리스트에 추가
      arriveInfoList.add(ArriveInfo(arriveDateTime: arriveDateTime));
    }

    return arriveInfoList;
  }

  static Future<List<ArriveInfo>> fetchBusArriveInfoFromDb() async {
    QuerySnapshot<Map<String, dynamic>> allDocument = await FirebaseFirestore.instance.collection("exbus_arrival_info").get();

    List<ArriveInfo> arriveInfoList = [];

    for (var doc in allDocument.docs) {
      // Firestore의 Timestamp를 DateTime으로 변환
      DateTime arriveDateTime = (doc.data()['arriveDateTime'] as Timestamp).toDate();

      // ArriveInfo 객체 생성 및 리스트에 추가
      arriveInfoList.add(ArriveInfo(arriveDateTime: arriveDateTime));
    }

    return arriveInfoList;
  }

  static Future<List<ArriveInfo>> getTrainArriveInfoFromApi() async {
    List<ArriveInfo> result = [];
    String domain = 'api.odsay.com';
    String path = '/v1/api/trainServiceTime';
    String apiKey = 'iE2lZJv98qcAWKJF7aQ5o6JXe2YsGiHAIUjI18ybVvU';
    String gumiStationId = "3300031";
    List<String> beginStationIdList = ["3300128", "3300065", "3300074"];

    for(String beginStationId in beginStationIdList){
      Uri uri = Uri.https(domain, path, {
        "apiKey": apiKey,
        "startStationID": beginStationId,
        "endStationID": gumiStationId
      });

      final http.Response response = await http.get(uri);
      if (response.statusCode == 500) { // 요청 실패할 경우 빈 리스트 반환
        return result;
      }
      List<dynamic> arriveInfoList = json.decode(response.body)["result"]["station"];
      for(var json in arriveInfoList){
        final String runDay = json["runDay"];
        final DateTime now = DateTime.now();
        final bool isWeekendToday = (now.weekday == 6 || now.weekday == 7);
        final bool isWeekendRunDay = (runDay == "토일");
        if(! isWeekendToday & isWeekendRunDay){ // 오늘은 주말인데, 도착정보가 주말 운영 정보일 때
          continue;
        }
        result.add(ArriveInfo.fromTrainJson(json));
      }
    }

    return result;
  }

  static Future<List<ArriveInfo>> getBusArriveInfoFromApi() async {
    List<ArriveInfo> result = [];

    String domain = 'api.odsay.com';
    String apiKey = 'iE2lZJv98qcAWKJF7aQ5o6JXe2YsGiHAIUjI18ybVvU';
    String gumiStationId = "4000170";

    // api로부터 고속버스 도착 정보 가져오기
    String expressBusPath = '/v1/api/expressServiceTime';
    List<String> expressBeginStationIdList = ["4000038", "4000175", "4000057"];
    for(String expressBeginStationId in expressBeginStationIdList){
      Uri uri = Uri.https(domain, expressBusPath, {
        "apiKey": apiKey,
        "startStationID": expressBeginStationId,
        "endStationID": gumiStationId
      });

      final http.Response response = await http.get(uri);
      if (response.statusCode == 500) { // 요청 실패할 경우 빈 리스트 반환
        return result;
      }
      List<dynamic> arriveInfoList = json.decode(response.body)["result"]["station"];
      for(var json in arriveInfoList){
        // result.add(ArriveInfo.fromJson(json));
        List<ArriveInfo> putArriveInfoList = fromBusJson(json);
        result.addAll(putArriveInfoList);
      }
    }

    // api로부터 시외버스 도착 정보 가져오기
    String interCityBusPath = '/v1/api/intercityServiceTime';
    List<String> interBeginStationIdList =
        ["3601075", "3600210", "3600529", "4000122", "3600164", "3600938", "3600028", "3600844",
          "3600042", "3600290", "4000112", "3601540", "3601542", "4000020", "4000156", "4000221",
          "3600728", "4000185", "3600763", "3600729", "4000173", "3600990", "4000169", "4000137",
          "4000067", "4000052", "3600324", "4000155", "3600050", "3601002", "4000309", "4000097",
          "4000302", "4000074", "4000176", "4000174", "3600541", "4000062", "4000294", "4000150",
          "4000290", "4000058", "4000035"];
    for(String expressBeginStationId in interBeginStationIdList){
      Uri uri = Uri.https(domain, interCityBusPath, {
        "apiKey": apiKey,
        "startStationID": expressBeginStationId,
        "endStationID": gumiStationId
      });

      final http.Response response = await http.get(uri);
      if (response.statusCode == 500) { // 요청 실패할 경우 빈 리스트 반환
        return result;
      }
      List<dynamic> arriveInfoList = json.decode(response.body)["result"]["station"];
      for(var json in arriveInfoList){
        // result.add(ArriveInfo.fromJson(json));
        List<ArriveInfo> putArriveInfoList = fromBusJson(json);
        result.addAll(putArriveInfoList);
      }
    }
    
    return result;
  }
}