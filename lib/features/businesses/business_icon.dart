import 'package:flutter/material.dart';

/// Business icon rendered as an emoji (restored from the old CustomPaint letters).
class BusinessIcon extends StatelessWidget {
  final String iconId;
  final double size;

  const BusinessIcon({super.key, required this.iconId, this.size = 26});

  static const Map<String, String> _emojis = {
    'lemonade': '\u{1F34B}', // 🍋
    'shawarma': '\u{1F32F}', // 🌯
    'pizza': '\u{1F355}', // 🍕
    'coffee': '\u2615', // ☕
    'market': '\u{1F3EA}', // 🏪
    'hotel': '\u{1F3E8}', // 🏨
    'factory': '\u{1F3ED}', // 🏭
    'power': '\u26A1', // ⚡
    'bank': '\u{1F3E6}', // 🏦
    'oil': '\u{1F6E2}\uFE0F', // 🛢️
    'ai': '\u{1F916}', // 🤖
    'space': '\u{1F680}', // 🚀
    'city': '\u{1F3D9}\uFE0F', // 🏙️
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _emojis[iconId] ?? '\u{1F4BC}'; // 💼 default
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.85),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
