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

class _LetterTracingScreenState extends State<LetterTracingScreen> {
  final LetterRepository _repository = LetterRepositoryImpl();
  final List<List<Offset>> _strokes = []; // List of strokes, each stroke is a list of points
  bool isCompleted = false;
  int currentLetterIndex = 0;
  late String currentLanguage;
  late List<Letter> currentLetters;
  final GlobalKey _drawingAreaKey = GlobalKey(); // Key for the drawing area
  bool _showNotebookLines = true; // Toggle for notebook lines visibility

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
              _strokes.clear(); // Clear all strokes when language changes
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
        key: _drawingAreaKey, // Assign the key to the drawing area
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Notebook page lines (conditionally shown)
            if (_showNotebookLines)
              Image.asset(
                'lib/assets/notebook_lines.jpg', // Path to your notebook lines PNG
                fit: BoxFit.cover, // Stretch the image to cover the drawing area
                width: double.infinity,
                height: double.infinity,
              ),
            // Letter template (dynamically generated)
            Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: LetterPainter(
                  letter: currentLetters[currentLetterIndex].unicode,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
            ),
            // Drawing area
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  // Start a new stroke
                  _strokes.add([]);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  // Use the correct RenderBox for the drawing area
                  RenderBox renderBox = _drawingAreaKey.currentContext!.findRenderObject() as RenderBox;
                  Offset localPosition = renderBox.globalToLocal(details.globalPosition);
                  // Add the point to the current stroke
                  _strokes.last.add(localPosition);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  isCompleted = _checkCompletion();
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: DrawingCanvas(strokes: _strokes), // Pass all strokes to the canvas
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
          // Toggle notebook lines button
          IconButton(
            icon: Icon(
              _showNotebookLines ? Icons.grid_off : Icons.grid_on,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                _showNotebookLines = !_showNotebookLines; // Toggle visibility
              });
            },
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
      _strokes.clear(); // Clear all strokes
      isCompleted = false;
    });
  }

  void _nextLetter() {
    setState(() {
      _strokes.clear(); // Clear all strokes
      currentLetterIndex = (currentLetterIndex + 1) % currentLetters.length;
      isCompleted = false;
    });
  }

  bool _checkCompletion() {
    if (_strokes.isEmpty || _strokes.last.length < 50) return false;

    // Calculate the accuracy of the user's drawing
    double accuracy = _calculateAccuracy();
    return accuracy > 0.7; // Consider it correct if accuracy is above 70%
  }

  double _calculateAccuracy() {
    // Get the expected path for the current letter
    List<Offset> expectedPath = _getExpectedPath(currentLetters[currentLetterIndex].unicode);

    // Flatten all user strokes into a single list of points
    List<Offset> userPath = _strokes.expand((stroke) => stroke).toList();

    // Compare the user's path with the expected path
    double totalDistance = 0;
    for (Offset userPoint in userPath) {
      double minDistance = double.infinity;
      for (Offset expectedPoint in expectedPath) {
        double distance = (userPoint - expectedPoint).distance;
        if (distance < minDistance) {
          minDistance = distance;
        }
      }
      totalDistance += minDistance;
    }

    // Normalize the accuracy score
    double maxDistance = _getMaxDistance(expectedPath);
    double accuracy = 1.0 - (totalDistance / (userPath.length * maxDistance));
    return accuracy.clamp(0.0, 1.0); // Ensure accuracy is between 0 and 1
  }

  List<Offset> _getExpectedPath(String unicode) {
    // Define the expected path for each letter
    // This is a simplified example; you can use more complex logic or data
    switch (unicode) {
      case 'A':
        return [
          Offset(50, 200),
          Offset(150, 50),
          Offset(250, 200),
          Offset(200, 150),
          Offset(100, 150),
        ];
      case 'B':
        return [
          Offset(50, 50),
          Offset(50, 200),
          Offset(150, 200),
          Offset(200, 150),
          Offset(150, 100),
          Offset(50, 100),
        ];
      default:
        return [];
    }
  }

  double _getMaxDistance(List<Offset> path) {
    // Calculate the maximum possible distance between points in the path
    double maxDistance = 0;
    for (int i = 0; i < path.length - 1; i++) {
      double distance = (path[i] - path[i + 1]).distance;
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }
    return maxDistance;
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

/// CustomPainter to draw the letter based on its Unicode representation
class LetterPainter extends CustomPainter {
  final String letter;
  final Color color;

  LetterPainter({required this.letter, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: 200, // Adjust the size of the letter
      color: color,
      fontFamily: 'Arial', // Use a font that supports the Unicode character
    );

    final textSpan = TextSpan(text: letter, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(LetterPainter oldDelegate) =>
      oldDelegate.letter != letter || oldDelegate.color != color;
}