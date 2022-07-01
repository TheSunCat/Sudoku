import 'dart:math';

import 'package:flutter/material.dart';

class LogoPainter extends CustomPainter {
  final double stroke = 10;

  Color color;
  LogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {


    var paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..isAntiAlias = true;

    // horizontal lines
    drawLineSmooth(canvas, paint, Offset(0, size.height / 3), Offset(size.width, size.height / 3));
    drawLineSmooth(canvas, paint, Offset(0, 2 * size.height / 3), Offset(size.width, 2 * size.height / 3));

    // vertical lines
    drawLineSmooth(canvas, paint, Offset(size.width / 3, 0), Offset(size.width / 3, size.height));
    drawLineSmooth(canvas, paint, Offset(2 * size.width / 3, 0), Offset(2 * size.width / 3, size.height));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  void drawLineSmooth(Canvas canvas, Paint paint, Offset start, Offset end)
  {
    canvas.drawLine(start, end, paint);
    canvas.drawArc(
        Rect.fromCenter(center: start, width: stroke, height: stroke),
        0, 2*pi,
        true,
        paint);
    canvas.drawArc(
        Rect.fromCenter(center: end, width: stroke, height: stroke),
        0, 2*pi,
        true,
        paint);
  }
}