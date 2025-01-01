import 'package:flutter/material.dart';
import '../../domain/entities/letter.dart';
import '../../domain/repositories/letter_repository_impl.dart';
import '../../domain/repositories/letter_repository.dart';
import '../widgets/drawing_canvas.dart';

class LetterTracingScreen extends StatefulWidget {
  const LetterTracingScreen({Key? key}) : super(key: key);

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

// Continuing from the previous LetterTracingScreen class...

class _LetterTracingScreenState extends State<LetterTracingScreen> {
  final LetterRepository _repository = LetterRepositoryImpl();
  final List<Offset> _points = [];
  bool isCompleted = false;
  int currentLetterIndex = 0;
  late String currentLanguage;
  late List<Letter> currentLetters;

  @override
  void initState() {
    super.initState();
    currentLanguage = _repository.getAvailableLanguages().first;
    currentLetters = _repository.getLettersByLanguage(currentLanguage);
  }

  Widget _buildLanguageDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<String>(
        value: currentLanguage,
        items: _repository.getAvailableLanguages().map((String language) {
          return DropdownMenuItem<String>(
            value: language,
            child: Text(
              language,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              currentLanguage = newValue;
              currentLetters = _repository.getLettersByLanguage(newValue);
              currentLetterIndex = 0;
              _points.clear();
              isCompleted = false;
            });
          }
        },
      ),
    );
  }

  Widget _buildDrawingArea() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Letter template image
            Center(
              child: Image.asset(
                currentLetters[currentLetterIndex].imagePath,
                color: Colors.grey.withOpacity(0.5),
                fit: BoxFit.contain,
                height: 300,
              ),
            ),
            // Drawing area
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  Offset localPosition = renderBox.globalToLocal(details.globalPosition);
                  _points.add(localPosition);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  isCompleted = _checkCompletion();
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: DrawingCanvas(points: _points),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            onPressed: _clearDrawing,
            icon: Icons.clear,
            label: 'Clear',
          ),
          _buildButton(
            onPressed: _nextLetter,
            icon: Icons.arrow_forward,
            label: 'Next Letter',
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildCompletionMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Great job writing "${currentLetters[currentLetterIndex].name}"!',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _clearDrawing() {
    setState(() {
      _points.clear();
      isCompleted = false;
    });
  }

  void _nextLetter() {
    setState(() {
      _points.clear();
      currentLetterIndex = (currentLetterIndex + 1) % currentLetters.length;
      isCompleted = false;
    });
  }

  bool _checkCompletion() {
    if (_points.length < 50) return false;

    // Calculate the covered area
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (Offset point in _points) {
      minX = point.dx < minX ? point.dx : minX;
      maxX = point.dx > maxX ? point.dx : maxX;
      minY = point.dy < minY ? point.dy : minY;
      maxY = point.dy > maxY ? point.dy : maxY;
    }

    // Check if the drawing covers a significant area
    double areaWidth = maxX - minX;
    double areaHeight = maxY - minY;
    double containerWidth = context.size?.width ?? 0;
    double containerHeight = context.size?.height ?? 0;

    return areaWidth > containerWidth * 0.3 &&
        areaHeight > containerHeight * 0.3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn to Write!'),
        actions: [_buildLanguageDropdown()],
      ),
      body: Column(
        children: [
          _buildDrawingArea(),
          _buildControlButtons(),
          if (isCompleted) _buildCompletionMessage(),
        ],
      ),
    );
  }
}