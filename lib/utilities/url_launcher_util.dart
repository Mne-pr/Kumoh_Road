import 'package:url_launcher/url_launcher.dart';
/**
 * url 주소를 이용해서 화면을 전환할 수 있도록 한다.
 * pageUrl에 url값을 String 타입으로 담는다.
 */
Future<void> launchURL(String pageUrl) async {
  final url = Uri.parse(pageUrl);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
