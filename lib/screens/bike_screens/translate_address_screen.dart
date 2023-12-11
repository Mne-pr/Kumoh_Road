import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'preview_location.dart';
import '../../utilities/bike_util.dart';

class TranslateAddressScreen extends StatefulWidget {
  const TranslateAddressScreen({Key? key}) : super(key: key);

  @override
  _TranslateAddressScreenState createState() => _TranslateAddressScreenState();
}

class _TranslateAddressScreenState extends State<TranslateAddressScreen> with AddressChangeClass, PathDataClass {
  String key = 'devU01TX0FVVEgyMDIzMTIwNTE1NTE0OTExNDMzNTM=';
  final addressText = TextEditingController();
  List<AddressData> addressList = <AddressData>[
    AddressData('구미역', '경북 구미시 구미중앙로 76'),
    AddressData('구미종합터미널', '경북 구미시 송원동로 72'),
    AddressData('금오공과대학교(양호동)', '경북 구미시 대학로 61')
  ];
  double marginSize = 10;
  FocusNode inputTextFocus = FocusNode();

  Widget buildListTile(AddressData data) {
    return ListTile(
      title: Text(data.addressName),
      subtitle: Text(data.address),
      onTap: () {
        Navigator.pop(context, data.address);
      },
      trailing: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(
          Icons.location_on,
          size: 30,
          color: Color(0xFF3F51B5),
        ),
        onPressed: () async {
          inputTextFocus.unfocus();
          Point tmp = await changeCoordinate(data.address);
          Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewLocation(tmp)));
        },
      ),
    );
  }

  void renewalList(String buildingName) async {
    List<AddressData> tmp = await getAddressList(buildingName);
    setState(() {
      addressList = tmp;
    });
  }

  @override
  void dispose() {
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
                    margin: EdgeInsets.fromLTRB(5, marginSize, 5, 5),
                    height: 35,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.chevron_left,
                              size: 30,
                              color: Color(0xFF3F51B5),
                            ),
                            onPressed: () => {
                              Navigator.pop(context),
                            },
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - marginSize * 2 - 35),
                          height: 35,
                          child: TextField(
                            textAlignVertical: TextAlignVertical.bottom,
                            textAlign: TextAlign.left,
                            maxLength: 23,
                            controller: addressText,
                            focusNode: inputTextFocus,
                            onSubmitted: (text) => {
                              inputTextFocus.unfocus(),
                              renewalList(addressText.text),
                            },
                            onTapOutside: (text) => {
                              inputTextFocus.unfocus(),
                            },
                            decoration: const InputDecoration(
                              counterText: "",
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
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width - marginSize),
                      height: 35,
                      child: TextButton.icon(
                        onPressed: () => {
                          inputTextFocus.unfocus(),
                          renewalList(addressText.text),
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(5),
                          backgroundColor: const Color(0xFF3F51B5),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        icon: const Icon(Icons.search, size:20, color: Colors.white),
                        label: const Text("검색"),
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
