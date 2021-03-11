import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

Future<void> copyToClipBoard(String copyText) async {
  await Clipboard.setData(ClipboardData(text: copyText));
  try {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
  } finally {
    print("Copied $copyText");
  }
}
