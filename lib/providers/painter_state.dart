import 'package:flutter/material.dart';
import '../models/shape.dart';

class PainterState extends ChangeNotifier {
  final List<Shape> shapes = [];
  ShapeType currentShape = ShapeType.rectangle;
  Color currentColor = Colors.blue;
  double strokeWidth = 2.0;
  Shape? currentDrawing;
  bool isSymmetricMode = false;
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool isErasing = false;

  void startDrawing(Offset position) {
    if (isErasing) {
      _eraseAt(position);
    } else {
      currentDrawing = Shape(
        type: currentShape,
        start: position,
        end: position,
        color: currentColor,
        strokeWidth: strokeWidth,
        isSymmetric: isSymmetricMode,
      );
    }
    notifyListeners();
  }

  void updateDrawing(Offset position) {
    if (isErasing) {
      _eraseAt(position);
    } else if (currentDrawing != null) {
      currentDrawing = Shape(
        type: currentDrawing!.type,
        start: currentDrawing!.start,
        end: position,
        color: currentDrawing!.color,
        strokeWidth: currentDrawing!.strokeWidth,
        isSymmetric: isSymmetricMode,
      );
    }
    notifyListeners();
  }

  void endDrawing() {
    if (currentDrawing != null && !isErasing) {
      shapes.add(currentDrawing!);
      currentDrawing = null;
      notifyListeners();
    }
  }

  void _eraseAt(Offset position) {
    final eraseRadius = strokeWidth / 2;
    shapes.removeWhere((shape) {
      if (shape.type == ShapeType.eraser) return false;
      
      final path = shape.getPath();
      final metric = path.computeMetrics().first;
      final length = metric.length;
      var distance = 0.0;
      
      while (distance < length) {
        final pos = metric.getTangentForOffset(distance)?.position;
        if (pos != null) {
          final dx = pos.dx - position.dx;
          final dy = pos.dy - position.dy;
          if (dx * dx + dy * dy <= eraseRadius * eraseRadius) {
            return true;
          }
        }
        distance += 5; // Шаг проверки
      }
      return false;
    });
  }

  void setShape(ShapeType shape) {
    currentShape = shape;
    isErasing = shape == ShapeType.eraser;
    notifyListeners();
  }

  void setColor(Color color) {
    currentColor = color;
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
    notifyListeners();
  }

  void toggleSymmetricMode() {
    isSymmetricMode = !isSymmetricMode;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void clear() {
    shapes.clear();
    notifyListeners();
  }

  void undo() {
    if (shapes.isNotEmpty) {
      shapes.removeLast();
      notifyListeners();
    }
  }
}
