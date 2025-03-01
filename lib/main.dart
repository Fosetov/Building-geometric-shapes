import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'models/shape.dart';
import 'providers/painter_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Geometric Painter');
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(Size.infinite);
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => PainterState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<PainterState>(context);
    return MaterialApp(
      title: 'Geometric Painter',
      themeMode: state.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.grey[100]!,
          surfaceContainerHighest: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Colors.grey[900]!,
          surfaceContainerHighest: const Color(0xFF1A1A1A),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const PainterScreen(),
    );
  }
}

class PainterScreen extends StatefulWidget {
  const PainterScreen({super.key});

  @override
  State<PainterScreen> createState() => _PainterScreenState();
}

class _PainterScreenState extends State<PainterScreen> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<PainterState>(context);
    
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isControlPressed) {
          state.isSymmetricMode = true;
        } else {
          state.isSymmetricMode = false;
        }
        
        if (event.isKeyPressed(LogicalKeyboardKey.keyZ) && event.isControlPressed) {
          state.undo();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        body: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToolButton(
                    Icons.rectangle_outlined,
                    'Прямоугольник',
                    onTap: () => state.setShape(ShapeType.rectangle),
                    isSelected: state.currentShape == ShapeType.rectangle,
                  ),
                  _buildToolButton(
                    Icons.circle_outlined,
                    'Круг',
                    onTap: () => state.setShape(ShapeType.circle),
                    isSelected: state.currentShape == ShapeType.circle,
                  ),
                  _buildToolButton(
                    Icons.change_history_outlined,
                    'Треугольник',
                    onTap: () => state.setShape(ShapeType.triangle),
                    isSelected: state.currentShape == ShapeType.triangle,
                  ),
                  _buildToolButton(
                    Icons.horizontal_rule,
                    'Линия',
                    onTap: () => state.setShape(ShapeType.line),
                    isSelected: state.currentShape == ShapeType.line,
                  ),
                  _buildToolButton(
                    Icons.auto_fix_high,
                    'Ластик',
                    onTap: () => state.setShape(ShapeType.eraser),
                    isSelected: state.currentShape == ShapeType.eraser,
                  ),
                  const Divider(height: 32),
                  _buildToolButton(
                    Icons.palette_outlined,
                    'Цвет',
                    onTap: () => _showColorPicker(context, state),
                  ),
                  _buildToolButton(
                    Icons.format_size,
                    'Размер',
                    onTap: () => _showStrokeWidthPicker(context, state),
                  ),
                  _buildToolButton(
                    Icons.settings,
                    'Настройки',
                    onTap: () => _showSettings(context, state),
                  ),
                  const Spacer(),
                  _buildToolButton(
                    Icons.undo,
                    'Отменить',
                    onTap: () => state.undo(),
                  ),
                  _buildToolButton(
                    Icons.delete_outline,
                    'Очистить',
                    onTap: () => state.clear(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => GestureDetector(
                  onPanStart: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final offset = box.globalToLocal(details.globalPosition);
                    // Учитываем отступы контейнера
                    final adjustedOffset = Offset(
                      offset.dx - 24,
                      offset.dy - 24
                    );
                    state.startDrawing(adjustedOffset);
                  },
                  onPanUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final offset = box.globalToLocal(details.globalPosition);
                    // Учитываем отступы контейнера
                    final adjustedOffset = Offset(
                      offset.dx - 24,
                      offset.dy - 24
                    );
                    state.updateDrawing(adjustedOffset);
                  },
                  onPanEnd: (details) {
                    state.endDrawing();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withAlpha(26),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: ShapePainter(
                          shapes: state.shapes,
                          currentDrawing: state.currentDrawing,
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String tooltip, {VoidCallback? onTap, bool isSelected = false}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, PainterState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите цвет'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: state.currentColor,
            onColorChanged: state.setColor,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStrokeWidthPicker(BuildContext context, PainterState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Размер линии'),
        content: SizedBox(
          width: 300,
          height: 80,
          child: Column(
            children: [
              Slider(
                value: state.strokeWidth,
                min: 1,
                max: 20,
                divisions: 19,
                label: state.strokeWidth.round().toString(),
                onChanged: (value) {
                  state.setStrokeWidth(value);
                },
              ),
              Text('${state.strokeWidth.round()} px'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, PainterState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Тема'),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Светлая'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Тёмная'),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Системная'),
                ),
              ],
              selected: {state.themeMode},
              onSelectionChanged: (values) {
                if (values.isNotEmpty) {
                  state.setThemeMode(values.first);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Горячие клавиши:'),
            const SizedBox(height: 8),
            const Text('• Ctrl + Z - отменить последнее действие'),
            const Text('• Ctrl (удерживать) - симметричный режим'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Shape> shapes;
  final Shape? currentDrawing;

  ShapePainter({
    required this.shapes,
    this.currentDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in shapes) {
      final paint = Paint()
        ..color = shape.color
        ..strokeWidth = shape.strokeWidth
        ..style = PaintingStyle.stroke;
      
      canvas.drawPath(shape.getPath(), paint);
    }

    if (currentDrawing != null) {
      final paint = Paint()
        ..color = currentDrawing!.color
        ..strokeWidth = currentDrawing!.strokeWidth
        ..style = PaintingStyle.stroke;
      
      canvas.drawPath(currentDrawing!.getPath(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return shapes != oldDelegate.shapes || currentDrawing != oldDelegate.currentDrawing;
  }
}
