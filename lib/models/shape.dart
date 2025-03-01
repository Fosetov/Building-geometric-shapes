import 'package:flutter/material.dart';
import 'dart:math' as math;

enum ShapeType {
  rectangle,
  circle,
  triangle,
  line,
  eraser,
}

class Shape {
  final ShapeType type;
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final bool isSymmetric;

  Shape({
    required this.type,
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 2.0,
    this.isSymmetric = false,
  });

  Path getPath() {
    final path = Path();
    switch (type) {
      case ShapeType.rectangle:
        if (isSymmetric) {
          final size = math.max(
            (end.dx - start.dx).abs(),
            (end.dy - start.dy).abs(),
          );
          final dx = size * (end.dx > start.dx ? 1 : -1);
          final dy = size * (end.dy > start.dy ? 1 : -1);
          path.addRect(Rect.fromPoints(
            start,
            Offset(start.dx + dx, start.dy + dy),
          ));
        } else {
          path.addRect(Rect.fromPoints(start, end));
        }
        break;
      case ShapeType.circle:
        if (isSymmetric) {
          final dx = end.dx - start.dx;
          final dy = end.dy - start.dy;
          final radius = math.sqrt(dx * dx + dy * dy) / 2;
          final center = Offset(
            start.dx + dx / 2,
            start.dy + dy / 2
          );
          path.addOval(
            Rect.fromCenter(
              center: center,
              width: radius * 2,
              height: radius * 2,
            ),
          );
        } else {
          path.addOval(Rect.fromLTRB(
            start.dx,
            start.dy,
            end.dx,
            end.dy,
          ));
        }
        break;
      case ShapeType.triangle:
        if (isSymmetric) {
          final size = math.max(
            (end.dx - start.dx).abs(),
            (end.dy - start.dy).abs(),
          );
          final dx = size * (end.dx > start.dx ? 1 : -1);
          final dy = size * (end.dy > start.dy ? 1 : -1);
          path.moveTo(start.dx + dx / 2, start.dy);
          path.lineTo(start.dx + dx, start.dy + dy);
          path.lineTo(start.dx, start.dy + dy);
          path.close();
        } else {
          path.moveTo(start.dx + (end.dx - start.dx) / 2, start.dy);
          path.lineTo(end.dx, end.dy);
          path.lineTo(start.dx, end.dy);
          path.close();
        }
        break;
      case ShapeType.line:
        if (isSymmetric) {
          final dx = end.dx - start.dx;
          final dy = end.dy - start.dy;
          if (dx.abs() > dy.abs()) {
            path.moveTo(start.dx, start.dy);
            path.lineTo(end.dx, start.dy);
          } else {
            path.moveTo(start.dx, start.dy);
            path.lineTo(start.dx, end.dy);
          }
        } else {
          path.moveTo(start.dx, start.dy);
          path.lineTo(end.dx, end.dy);
        }
        break;
      case ShapeType.eraser:
        path.addOval(Rect.fromCircle(
          center: end,
          radius: strokeWidth / 2,
        ));
        break;
    }
    return path;
  }
}
