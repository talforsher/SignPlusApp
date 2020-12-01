// conditional library returned html
import 'package:url_launcher/url_launcher.dart';

class UrlUtils {
  UrlUtils._();
  static void open(String url, {String name}) {
    launch(url);
  }
}
