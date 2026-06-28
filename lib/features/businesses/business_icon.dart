import 'package:flutter/material.dart';
import '../../core/theme.dart';

class BusinessIcon extends StatelessWidget {
  final String iconId;
  final double size;

  const BusinessIcon({super.key, required this.iconId, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BusinessIconPainter(iconId: iconId),
    );
  }
}

class _BusinessIconPainter extends CustomPainter {
  final String iconId;
  _BusinessIconPainter({required this.iconId});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    switch (iconId) {
      case 'lemonade':
        // Yellow circle with L
        paint.color = const Color(0xFFFFD700);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'L', Colors.white);
        break;
      case 'shawarma':
        // Orange circle with S
        paint.color = const Color(0xFFFF8C00);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'S', Colors.white);
        break;
      case 'pizza':
        // Red circle with P
        paint.color = const Color(0xFFE74C3C);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'P', Colors.white);
        break;
      case 'coffee':
        // Brown circle with C
        paint.color = const Color(0xFF795548);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'C', Colors.white);
        break;
      case 'market':
        // Green circle with M
        paint.color = const Color(0xFF27AE60);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'M', Colors.white);
        break;
      case 'hotel':
        // Blue circle with H
        paint.color = const Color(0xFF2980B9);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'H', Colors.white);
        break;
      case 'factory':
        // Grey circle with F
        paint.color = const Color(0xFF7F8C8D);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'F', Colors.white);
        break;
      case 'power':
        // Yellow-green circle with E
        paint.color = const Color(0xFFF39C12);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'E', Colors.white);
        break;
      case 'bank':
        // Dark blue circle with B
        paint.color = const Color(0xFF1A237E);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'B', Colors.white);
        break;
      case 'oil':
        // Black circle with O
        paint.color = const Color(0xFF212121);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'O', const Color(0xFFFFD700));
        break;
      case 'ai':
        // Purple circle with AI
        paint.color = const Color(0xFF7F77DD);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'AI', Colors.white, fontSize: 0.35);
        break;
      case 'space':
        // Dark purple circle with R
        paint.color = const Color(0xFF4A148C);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'R', Colors.white);
        break;
      case 'city':
        // Teal circle with C
        paint.color = const Color(0xFF00695C);
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, 'C', Colors.white);
        break;
      default:
        paint.color = AppColors.accent;
        canvas.drawCircle(center, r, paint);
        _drawLetter(canvas, size, '?', Colors.white);
    }
  }

  void _drawLetter(Canvas canvas, Size size, String letter, Color color, {double fontSize = 0.45}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          color: color,
          fontSize: size.width * fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
