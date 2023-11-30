import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String address = '';
  String currentTemperature = '';
  String weatherStatus = '';
  List<String> airQuality = [];
  List<String> hourlyWeather = [];

  @override
  void initState() {
    super.initState();
    loadWeatherData();
  }

  void loadWeatherData() async {
    try {
      final response = await http.get(Uri.parse('https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=0&ie=utf8&query=%EA%B5%AC%EB%AF%B8+%EB%82%A0%EC%94%A8'));
      dom.Document document = parser.parse(response.body);

      // 주소
      var addressElement = document.querySelector('.title_area._area_panel h2.title');
      // 현재 온도
      var temperatureElement = document.querySelector('.temperature_text');
      // 날씨 상태
      var weatherStatusElement = document.querySelector('.weather.before_slash');
      // 미세 먼지 정보
      var airQualityElements = document.querySelectorAll('.today_chart_list .item_today');
      // 시간대별 날씨 정보
      var hourlyWeatherElements = document.querySelectorAll('._li');

      setState(() {
        address = addressElement != null ? addressElement.text : '주소를 불러올 수 없습니다.';
        currentTemperature = temperatureElement != null ? temperatureElement.text.trim().substring(5) : '온도를 불러올 수 없습니다.';
        weatherStatus = weatherStatusElement != null ? weatherStatusElement.text : '날씨 상태를 불러올 수 없습니다.';
        airQuality = airQualityElements.map((element) => element.text.trim()).toList();
        hourlyWeather = hourlyWeatherElements.map((element) => element.text.trim()).toList();
      });
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        address = '데이터를 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('날씨 정보', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('주소: $address', style: TextStyle(fontSize: 24)),
            Text('현재 온도: $currentTemperature', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('날씨 상태: $weatherStatus', style: TextStyle(fontSize: 20)),
            ...airQuality.map((quality) => Text(quality)).toList(),
            ...hourlyWeather.map((weather) => Text(weather)).toList(),
          ],
        ),
      ),
    );
  }
}
