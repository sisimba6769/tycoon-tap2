import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/game_provider.dart';
import '../core/theme.dart';
import '../widgets/glass_container.dart';

class NewsTicker extends ConsumerStatefulWidget {
  const NewsTicker({super.key});

  @override
  ConsumerState<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends ConsumerState<NewsTicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final isPositive = game.newsMultiplier >= 1.0;
    final newsColor = isPositive ? AppColors.accentLight : const Color(0xFFE74C3C);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: newsColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: newsColor.withOpacity(0.5)),
            ),
            child: Text(
              'LIVE',
              style: TextStyle(
                color: newsColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  return FractionalTranslation(
                    translation: Offset(1.0 - _scrollController.value * 2, 0),
                    child: child,
                  );
                },
                child: Text(
                  game.currentNewsText,
                  style: TextStyle(
                    color: newsColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (game.newsTimeRemaining > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: newsColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${game.newsTimeRemaining}s',
                style: TextStyle(
                  color: newsColor.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
