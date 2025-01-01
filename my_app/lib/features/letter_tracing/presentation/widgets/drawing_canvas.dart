import 'package:flutter/material.dart';

class DrawingCanvas extends CustomPainter {
final List<List<Offset>> strokes;

DrawingCanvas({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (final stroke in strokes) {
    for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
    }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}