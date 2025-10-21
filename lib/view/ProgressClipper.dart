import 'package:flutter/cupertino.dart';

class ProgressClipper extends CustomClipper<Rect> {
  final double width;
  ProgressClipper({required this.width});

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, width, size.height);

  @override
  bool shouldReclip(covariant ProgressClipper oldClipper) =>
      oldClipper.width != width;
}