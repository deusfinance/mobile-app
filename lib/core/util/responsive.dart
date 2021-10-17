import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getScreenWidth(BuildContext context) =>
    MediaQuery.of(context).size.width;

bool isPhone() => Device.get().isPhone;
