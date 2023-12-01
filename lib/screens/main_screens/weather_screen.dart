import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../bike_screens/path_map_screen.dart';
import '../bus_info_screens/bus_info_screen.dart';
import '../taxi_screens/taxi_screen.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future? _weatherDataFuture;

  String address = '';
  String currentTemperature = '';
  String weatherStatus = '';
  List<String> airQuality = [];
  List<String> hourlyWeather = [];

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = loadWeatherData();
  }

  Future<void> loadWeatherData() async {
    try {
      final response = await http.get(Uri.parse('https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=0&ie=utf8&query=%EA%B5%AC%EB%AF%B8+%EA%B1%B0%EC%9D%98%EB%8F%99+%EB%82%A0%EC%94%A8'));
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

  String getBackgroundImage() {
    if (weatherStatus.contains('맑음')) {
      return 'assets/images/weather_sunny.jpg';
    } else if (weatherStatus.contains('비') || weatherStatus.contains('소나기')) {
      return 'assets/images/weather_rainy.jpg';
    } else if (weatherStatus.contains('구름')) {
      return 'assets/images/weather_cloudy.jpg';
    } else if (weatherStatus.contains('눈')) {
      return 'assets/images/weather_snow.jpg';
    } else {
      return 'assets/images/weather_default.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _weatherDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          } else {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(getBackgroundImage()),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: _buildWeatherContent(),
            );
          }
        },
      ),
    );
  }

  Widget _buildWeatherContent() {
    return Column(
      children: [
        _buildAppBar(),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationTemperature(),
              _buildAirQuality(),
              _buildHourlyWeather(),
              const SizedBox(height: 10.0),  // 추가된 SizedBox 위젯
              _buildTransportRecommendation(context),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildLocationTemperature() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          address,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
        Text(
          currentTemperature,
          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAirQuality() {
    List<Widget> airQualityWidgets = [];

    for (var i = 0; i < airQuality.length; i++) {
      var quality = airQuality[i];
      var icon = Icons.error;
      var color = Colors.white;

      if (quality.contains('미세먼지')) {
        icon = Icons.grain;
        color = quality.contains('좋음') ? Colors.green : Colors.red;
      } else if (quality.contains('초미세먼지')) {
        icon = Icons.blur_on;
        color = quality.contains('좋음') ? Colors.green : Colors.red;
      } else if (quality.contains('자외선')) {
        icon = Icons.wb_sunny;
        color = quality.contains('좋음') ? Colors.yellow : Colors.orange;
      } else if (quality.contains('일출')) {
        icon = Icons.wb_twighlight;
      }

      if (i <= 3) {
        airQualityWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8.0),
                Text(quality, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: airQualityWidgets,
    );
  }

  Widget _buildHourlyWeather() {
    return SizedBox(
      height: 120, // 카드의 높이 조정
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyWeather.length < 8 ? hourlyWeather.length : 8, // 최대 5개 표시
        itemBuilder: (context, index) {
          var weatherData = hourlyWeather[index].split(' ');
          var time = weatherData[0];
          var weatherCondition = weatherData[2];
          var temperature = weatherData[7];

          IconData icon = Icons.error; // 기본 아이콘
          Color iconColor = Colors.black; // 기본 아이콘 색상

          // 날씨 상태에 따른 아이콘 설정
          if (weatherCondition.contains('맑음')) {
            icon = Icons.wb_sunny;
            iconColor = Colors.red;
          } else if (weatherCondition.contains('구름많음')) {
            icon = Icons.cloud_queue;
            iconColor = Colors.grey;
          } else if (weatherCondition.contains('흐림')) {
            icon = Icons.cloud;
            iconColor = Colors.blueGrey;
          } else if (weatherCondition.contains('비')) {
            icon = Icons.beach_access;
            iconColor = Colors.blue;
          } else if (weatherCondition.contains('소나기')) {
            icon = Icons.grain;
            iconColor = Colors.lightBlue;
          } else if (weatherCondition.contains('눈')) {
            icon = Icons.ac_unit;
            iconColor = Colors.white;
          }

          return Card(
            color: Colors.white.withOpacity(0.7),
            child: Container(
              width: 80, // 카드의 너비 조정
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(time, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3.0),
                  Icon(icon, color: iconColor, size: 48),
                  const SizedBox(height: 3.0),
                  Text(temperature, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransportRecommendation(BuildContext context) {
    IconData transportIcon;
    String recommendation;
    Widget Function() destinationScreen;

    // 날씨와 공기 질을 고려한 교통 수단 추천
    if (weatherStatus.contains('비') || weatherStatus.contains('눈')) {
      transportIcon = Icons.local_taxi;
      recommendation = '비나 눈이 오는 날엔 택시가 안전합니다.';
      destinationScreen = () => const TaxiScreen();
    } else if (currentTemperature.startsWith('-')) {
      transportIcon = Icons.directions_bus;
      recommendation = '추운 날씨에는 버스 이용을 추천드려요.';
      destinationScreen = () => const BusInfoScreen();
    } else if (airQuality.any((element) => element.contains('나쁨'))) {
      transportIcon = Icons.directions_walk;
      recommendation = '공기 질이 좋지 않을 땐 택시가 좋습니다.';
      destinationScreen = () => const TaxiScreen(); // 도보 관련 화면
    } else {
      transportIcon = Icons.pedal_bike;
      recommendation = '날씨가 좋으니 자전거로 활기찬 하루를 시작하세요!';
      destinationScreen = () => const PathMapScreen();
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // 라운드 코너 적용
      color: Colors.white.withOpacity(0.7),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
          leading: Icon(transportIcon, size: 30.0),
          title: Text(recommendation, style: const TextStyle(fontSize: 16.0, color: Colors.black)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationScreen()),
            );
          },
        ),
      ),
    );
  }
}
