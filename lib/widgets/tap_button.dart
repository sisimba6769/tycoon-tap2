import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/game_provider.dart';
import '../core/services/audio_service.dart';
import '../core/theme.dart';
import '../core/utils/number_formatter.dart';

class FloatingText {
  final String text;
  final Offset position;
  double opacity;
  double dy;

  FloatingText({required this.text, required this.position})
      : opacity = 1.0,
        dy = 0;
}

class TapButton extends ConsumerStatefulWidget {
  const TapButton({super.key});

  @override
  ConsumerState<TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends ConsumerState<TapButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  final List<FloatingText> _floatingTexts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 15, end: 35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    final game = ref.read(gameProvider);
    final income = game.tapPower * game.prestigeMultiplier * game.newsMultiplier;
    ref.read(gameProvider.notifier).tap();
    ref.read(audioServiceProvider).playTap();

    // Add floating text
    final rx = _random.nextDouble() * 60 - 30;
    final ry = _random.nextDouble() * 40 - 20;
    final ft = FloatingText(
      text: NumberFormatter.format(income),
      position: details.localPosition + Offset(rx, ry),
    );
    setState(() => _floatingTexts.add(ft));

    // Animate and remove
    _animateFloat(ft);
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  void _animateFloat(FloatingText ft) async {
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() {
        ft.dy -= 4;
        ft.opacity -= 0.05;
      });
    }
    if (mounted) setState(() => _floatingTexts.remove(ft));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Floating texts
          ..._floatingTexts.map((ft) => Positioned(
                left: 100 + ft.position.dx - 40,
                top: 100 + ft.position.dy + ft.dy - 20,
                child: Opacity(
                  opacity: ft.opacity.clamp(0.0, 1.0),
                  child: Text(
                    ft.text,
                    style: const TextStyle(
                      color: AppColors.accentLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: AppColors.accent, blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              )),
          // Glow ring
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, _) => Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: _glowAnim.value,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // Main button
          GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnim.value,
                child: child,
              ),
              child: Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2FCF99),
                      Color(0xFF1D9E75),
                      Color(0xFF0F6B50),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '💰',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
