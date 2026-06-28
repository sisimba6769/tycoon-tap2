import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/game_provider.dart';
import '../../core/theme.dart';
import '../../core/utils/number_formatter.dart';
import 'business_card.dart';

class BusinessesTab extends ConsumerWidget {
  const BusinessesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('🏢 Бизнесы',
                  style: TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Text('+${NumberFormatter.format(game.incomePerSecond)}/с',
                    style: const TextStyle(color: AppColors.accentLight, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        ...List.generate(
          game.businesses.length,
          (i) => BusinessCard(key: ValueKey(game.businesses[i].id), index: i),
        ),
      ],
    );
  }
}
