import '../../core/widgets/coming_soon_screen.dart';
import 'package:flutter/material.dart';

class BlurredSyntheticsScreen extends StatelessWidget {
  static const url = '/blurred-synthetics';

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      imgPath: 'assets/blur_screens/synthetics.jpg',
    );
  }
}
