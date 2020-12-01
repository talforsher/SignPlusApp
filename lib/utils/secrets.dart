import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class Secret {
  static const ANDROID_CLIENT_ID =
      "844058502646-adock8idf6euh6t3q8q9c1g9pspgu5vg.apps.googleusercontent.com";
  static const IOS_CLIENT_ID =
      "613879592880-fbido0l2kk6t31uo51gvqkdpsam3vqcj.apps.googleusercontent.com";
  static const WEB_CLIENT_ID =
      "844058502646-4bo4kbgg3kkdd6n0bs3dl18vlmdbf5rv.apps.googleusercontent.com";

  static String getId() => kIsWeb
      ? Secret.WEB_CLIENT_ID
      : Platform.isAndroid
          ? Secret.ANDROID_CLIENT_ID
          : Secret.IOS_CLIENT_ID;
}
