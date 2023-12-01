import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "package:http/http.dart" as http;

class TranslateAddressScreen extends StatefulWidget {
  const TranslateAddressScreen({Key? key}) : super(key: key);

  @override
  _TranslateAddressScreen createState() => _TranslateAddressScreen();
}

class AddressData{
  String addressName;
  String address;
  AddressData(this.addressName, this.address);
}

class _TranslateAddressScreen extends State<TranslateAddressScreen> {
  final addressText = TextEditingController();
  final addressList = <AddressData>[AddressData('구미역', '경북 구미시 구미중앙로 76'), AddressData('구미종합터미널', '경북 구미시 송원동로 72'), AddressData('금오공과대학교(양호동)', '경북 구미시 대학로 61')];
  double marginSize = 10;

  Widget buildListTile(AddressData data){
    return ListTile(
      title: Text(data.addressName),
      subtitle: Text(data.address),
      trailing: TextButton(
        child: const Text("선택"),
        onPressed: (){
          Navigator.pop(context, data.address);
        },
      ),
    );
  }

  @override
  void dispose(){
    addressText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double a = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              color: const Color(0xd0ffffff),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(marginSize, marginSize, marginSize, 5),
                    height: 35,
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width - marginSize * 2),
                      height: 35,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.bottom,
                        textAlign: TextAlign.left,
                        controller: addressText,
                        onSubmitted: (text) {},
                        decoration: const InputDecoration(
                          hintText: "주소를 입력하세요",
                          filled: true,
                          fillColor: Color(0xffdddddd),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black54,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.4, 5, MediaQuery.of(context).size.width * 0.4, 0),
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width - marginSize * 2),
                      height: 35,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context, addressText.text);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(5),
                          backgroundColor: const Color(0xff05d686),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        child: const Text('검색'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: addressList.map((data) => buildListTile(data)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
