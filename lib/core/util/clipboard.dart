import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

Future<void> copyToClipBoard(String copyText) async {
  await Clipboard.setData(ClipboardData(text: copyText));
  try {
    if (await Vibrate.canVibrate) {
      await Vibrate.vibrate();
    }
  } finally {
    // print("Copied $copyText");
  }
}
