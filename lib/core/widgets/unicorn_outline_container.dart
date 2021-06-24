import 'package:flutter/material.dart';

class UnicornOutlineContainer extends StatelessWidget {
  final CustomPainter _painter;
  final Widget _child;
  // final double _radius;

  UnicornOutlineContainer({
    required double strokeWidth,
    required Gradient gradient,
    required Widget child,
    double? radius,

    ///Liste der Radianten (BottomLeft, Bottom Right, TopLeft, TopRight).
    List<double>? cornerRadiusBLRTLR,
  })  : assert(radius != null || cornerRadiusBLRTLR != null),
        this._painter = cornerRadiusBLRTLR == null
            ? GradientPainter(strokeWidth: strokeWidth, radius: radius!, gradient: gradient)
            : CustomGradientPainter(
                strokeWidth: strokeWidth,
                bottomLeftRadius: cornerRadiusBLRTLR[0],
                bottomRightRadius: cornerRadiusBLRTLR[1],
                topLeftRadius: cornerRadiusBLRTLR[2],
                topRightRadius: cornerRadiusBLRTLR[3],
                gradient: gradient),
        this._child = child;
        // this._radius = radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 88,
          minHeight: 48,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _child,
          ],
        ),
      ),
    );
  }
}

class CustomGradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double bottomLeftRadius;
  final double bottomRightRadius;
  final double topLeftRadius;
  final double topRightRadius;
  final double strokeWidth;
  final Gradient gradient;

  CustomGradientPainter(
      {required double strokeWidth,
      required this.bottomLeftRadius,
      required this.bottomRightRadius,
      required this.topLeftRadius,
      required this.topRightRadius,
      required Gradient gradient})
      : this.strokeWidth = strokeWidth,
        this.gradient = gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    final Rect outerRect = Offset.zero & size;
    final outerRRect = RRect.fromRectAndCorners(outerRect,
        bottomLeft: Radius.circular(bottomLeftRadius),
        bottomRight: Radius.circular(bottomRightRadius),
        topLeft: Radius.circular(topLeftRadius),
        topRight: Radius.circular(topRightRadius));

    // create inner rectangle smaller by strokeWidth
    final Rect innerRect =
        Rect.fromLTWH(strokeWidth, strokeWidth, size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    final innerRRect = RRect.fromRectAndCorners(innerRect,
        bottomLeft: Radius.circular(bottomLeftRadius - strokeWidth),
        bottomRight: Radius.circular(bottomRightRadius - strokeWidth),
        topLeft: Radius.circular(topLeftRadius - strokeWidth),
        topRight: Radius.circular(topRightRadius - strokeWidth));

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    final Path path1 = Path()..addRRect(outerRRect);
    final Path path2 = Path()..addRRect(innerRRect);
    final path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  GradientPainter({required double strokeWidth, required double radius, required Gradient gradient})
      : this.strokeWidth = strokeWidth,
        this.radius = radius,
        this.gradient = gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    final Rect outerRect = Offset.zero & size;
    final outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    final Rect innerRect =
        Rect.fromLTWH(strokeWidth, strokeWidth, size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    final innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(radius - strokeWidth));

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    final Path path1 = Path()..addRRect(outerRRect);
    final Path path2 = Path()..addRRect(innerRRect);
    final path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
