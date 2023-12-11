import 'dart:io';
import 'dart:async';
import 'dart:convert';
import "package:http/http.dart";
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "package:geolocator/geolocator.dart";
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/bottom_navigation_bar.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class Point {
  int statusCode;
  int numResponse;
  String name;
  double lat;
  double lon;

  Point(this.statusCode, this.numResponse, this.name, this.lat, this.lon);
}

class AddressData {
  String addressName;
  String address;

  AddressData(this.addressName, this.address);
}

mixin PathDataClass {
  //변수
  Map<String, String> nMapApiKey = {"X-NCP-APIGW-API-KEY-ID": "t2v0aiyv0u", "X-NCP-APIGW-API-KEY": "R0ydnLxNcjSpxEf6jPt2YQQGE3TCE3UrV84AcSNx"};

  //함수
  Future<Point> changeCoordinate(String loadAddress) async {
    Response response = await get(Uri.parse("https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=$loadAddress"), headers: nMapApiKey);
    if (response.statusCode == 200) {
      String jsonData = utf8.decode(response.bodyBytes);
      int numResponse = jsonDecode(jsonData)["meta"]["totalCount"];
      if (numResponse >= 1) {
        String pointName = jsonDecode(jsonData)["addresses"][0]["addressElements"][6]["shortName"];
        double pointLat = double.parse(jsonDecode(jsonData)["addresses"][0]["y"]);
        double pointLon = double.parse(jsonDecode(jsonData)["addresses"][0]["x"]);
        Point tmpPoint = Point(response.statusCode, numResponse, pointName, pointLat, pointLon);
        return tmpPoint;
      } else {
        Point tmpPoint = Point(response.statusCode, numResponse, "-", 0, 0);
        return tmpPoint;
      }
    } else {
      Point tmpPoint = Point(response.statusCode, -1, "-", 0, 0);
      return tmpPoint;
    }
  }

//==============================
}

mixin AddressChangeClass {
  String addressApiKey = "devU01TX0FVVEgyMDIzMTIwNTE1NTE0OTExNDMzNTM=";
  List<AddressData> addressBaseDataList = [
    AddressData('구미역', '경북 구미시 구미중앙로 76'),
    AddressData('구미종합터미널', '경북 구미시 송원동로 72'),
    AddressData('금오공과대학교(양호동)', '경북 구미시 대학로 61')
  ];

  void errorView(String errorMessage) {
    Fluttertoast.showToast(
      msg: errorMessage,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      fontSize: 20.0,
      textColor: Colors.black,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  Future<List<AddressData>> getAddressList(String buildingName) async {
    int page = 1;
    int count = -500;
    int nameCount = 1;
    List<AddressData> tmp = [];
    do {
      Response response = await get(Uri.parse(
          "http://www.juso.go.kr/addrlink/addrLinkApi.do?currentPage=$page&countPerPage=10&keyword=$buildingName&confmKey=$addressApiKey&resultType=json"));
      String jsonData = utf8.decode(response.bodyBytes);
      if (count == -500) {
        count = int.parse(jsonDecode(jsonData)["results"]["common"]["totalCount"]);
      }
      if (count > 0) {
        print(count);
        for (int i = 0; i < count && i < 10; i++) {
          String tmp1 = jsonDecode(jsonData)["results"]["juso"][i]["bdNm"];
          if (tmp1 == "") {
            continue;
          }
          String tmp2 = jsonDecode(jsonData)["results"]["juso"][i]["roadAddrPart1"];
          tmp.add(AddressData("$nameCount. $tmp1", tmp2));
          nameCount++;
        }
        count -= 10;
        page += 1;
      } else {
        tmp = addressBaseDataList;
        errorView("검색 주소가 비어있거나 잘못되었습니다");
      }
    } while (count > 0);
    return tmp;
  }
}
