

class Station{
  late int stationID;

}



class BusStationInfoProviders{
  final int busKey;
  final String busURL = "https://api.odsay.com/v1/api/busStationInfo?lang=0&stationID=418134";

  BusStationInfoProviders({required this.busKey});

  // Future<List<dd>> getBusStationInfo() async {
  //
  // }


}


// void main() {
//   final String busURL = "https://api.odsay.com/v1/api/busStationInfo?lang=0&stationID=418134";
//   final busRequest = Uri.parse(busURL);
//   Future<dynamic> fetch() async {
//     final response = await http.get(busRequest);
//     print(jsonDecode(response.body));
//   }
// }