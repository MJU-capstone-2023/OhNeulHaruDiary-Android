import 'package:flutter/material.dart';

class TopRoundedRectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final radius = 30.0;
    final path = Path()
      ..moveTo(0, radius)
      ..arcToPoint(Offset(radius, 0),
          radius: Radius.circular(radius), clockwise: false)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(
          Offset(size.width, radius),
          radius: Radius.circular(radius),
          clockwise: false)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, radius);

    return path;
  }

  @override
  bool shouldReclip(TopRoundedRectangleClipper oldClipper) => false;
}
