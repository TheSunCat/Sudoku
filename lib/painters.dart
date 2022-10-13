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

// not my best code... 2: Electric Boogaloo
class EdgePainter extends CustomPainter {
  final Border _border;
  final bool _right, _bottom;

  EdgePainter(this._border, this._right, this._bottom);

  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height; // for convenient shortage
    double sw = size.width; // for convenient shortage

    if(_right) {
      double cornerSide = sh * 0.2; // desirable value for corners side
      if(_border.right.width > 1) {
        cornerSide = 0;
      }

      Paint rightPaint = Paint()
        ..color = _border.right.color
        ..strokeWidth = _border.right.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Path path = Path()
        ..moveTo(sw, cornerSide)
        ..lineTo(sw, sw - cornerSide);

      canvas.drawPath(path, rightPaint);
    }

    if(_bottom) {
      double cornerSide = sh * 0.2; // desirable value for corners side

      if(_border.bottom.width > 1) {
        cornerSide = 0;
      }

      Paint bottomPaint = Paint()
        ..color = _border.bottom.color
        ..strokeWidth = _border.bottom.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Path path = Path()
        ..moveTo(cornerSide, sh)
        ..lineTo(sw - cornerSide, sh);

      canvas.drawPath(path, bottomPaint);
    }
  }

  @override
  bool shouldRepaint(EdgePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(EdgePainter oldDelegate) => false;
}