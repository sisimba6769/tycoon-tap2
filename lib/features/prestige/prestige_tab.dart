import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/game_provider.dart';
import '../../core/theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../widgets/glass_container.dart';

class PrestigeTab extends ConsumerWidget {
  const PrestigeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final required = game.prestige1MRequirement;
    final canPrestige = game.money >= required;
    final progress = (game.money / required).clamp(0.0, 1.0);
    final nextMultiplier = 1.0 + (game.prestigeLevel + 1) * 0.5;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '⭐ Престиж',
          style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Начни заново с бонусом',
          style: TextStyle(
              color: AppColors.textColor.withOpacity(0.5), fontSize: 12),
        ),
        const SizedBox(height: 20),

        // Current prestige level
        GlassContainer(
          padding: const EdgeInsets.all(20),
          color: AppColors.purple.withOpacity(0.06),
          borderColor: AppColors.purple.withOpacity(0.25),
          child: Column(
            children: [
              const Text(
                '⭐',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                'Уровень Престижа: ${game.prestigeLevel}',
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Множитель: ×${game.prestigeMultiplier.toStringAsFixed(1)}',
                style: TextStyle(
                  color: AppColors.textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Progress to prestige
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Требуется',
                    style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.6),
                        fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormatter.format(required),
                    style: const TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.purple, Color(0xFF5B54D6)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.purple.withOpacity(0.5),
                            blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Текущий капитал: ${NumberFormatter.format(game.money)}',
                    style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.5),
                        fontSize: 11),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: AppColors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // What's lost / gained
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(14),
                color: const Color(0xFFE74C3C).withOpacity(0.06),
                borderColor: const Color(0xFFE74C3C).withOpacity(0.25),
                child: Column(
                  children: [
                    const Text('🗑️ Сброс', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),
                    ...[
                      'Деньги',
                      'Бизнесы',
                      'Менеджеры',
                      'Улучшения',
                    ].map((t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• $t',
                            style: const TextStyle(
                                color: Color(0xFFE74C3C), fontSize: 12),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(14),
                color: AppColors.accentLight.withOpacity(0.06),
                borderColor: AppColors.accentLight.withOpacity(0.25),
                child: Column(
                  children: [
                    const Text('✨ Бонус', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 8),
                    Text(
                      '+${game.prestigeLevel + 1} уровень',
                      style: const TextStyle(
                          color: AppColors.accentLight, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '×${nextMultiplier.toStringAsFixed(1)} к доходу',
                      style: const TextStyle(
                          color: AppColors.accentLight,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Акции сохранятся',
                      style: TextStyle(
                          color: AppColors.accentLight.withOpacity(0.7),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Prestige button
        GestureDetector(
          onTap: canPrestige
              ? () => _confirmPrestige(context, ref)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: canPrestige
                  ? const LinearGradient(
                      colors: [AppColors.purple, Color(0xFF5B54D6)])
                  : null,
              color: canPrestige ? null : AppColors.glass,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: canPrestige
                      ? AppColors.purple.withOpacity(0.6)
                      : AppColors.glassBorder),
              boxShadow: canPrestige
                  ? [
                      BoxShadow(
                          color: AppColors.purple.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2)
                    ]
                  : null,
            ),
            child: Text(
              canPrestige
                  ? '⭐ ПРЕСТИЖ! Уровень ${game.prestigeLevel + 1}'
                  : '⭐ Нужно ${NumberFormatter.format(required)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: canPrestige
                    ? Colors.white
                    : AppColors.textColor.withOpacity(0.3),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Rivals ranking
        _RivalsSection(),
      ],
    );
  }

  void _confirmPrestige(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('⭐ Подтвердить Престиж',
            style: TextStyle(color: AppColors.textColor)),
        content: const Text(
          'Ты потеряешь все бизнесы, деньги и менеджеров, но получишь постоянный бонус к доходу!',
          style: TextStyle(color: Color(0xFFB0B0C0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена',
                style: TextStyle(color: Color(0xFFB0B0C0))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(gameProvider.notifier).prestige();
            },
            child: const Text('Подтвердить',
                style: TextStyle(
                    color: AppColors.purple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _RivalsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final rivals = [...game.rivals]
      ..sort((a, b) => b.capital.compareTo(a.capital));
    final allEntries = [
      {'name': 'Ты', 'capital': game.money, 'isMe': true},
      ...rivals.map((r) => {'name': r.name, 'capital': r.capital, 'isMe': false}),
    ]..sort((a, b) =>
        (b['capital'] as double).compareTo(a['capital'] as double));

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 Рейтинг конкурентов',
            style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...List.generate(allEntries.length, (i) {
            final entry = allEntries[i];
            final isMe = entry['isMe'] as bool;
            final rank = i + 1;
            final rankEmoji = rank == 1
                ? '🥇'
                : rank == 2
                    ? '🥈'
                    : rank == 3
                        ? '🥉'
                        : '${rank}.';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.accent.withOpacity(0.12)
                    : AppColors.glass,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isMe
                        ? AppColors.accent.withOpacity(0.3)
                        : AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Text(rankEmoji,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry['name'] as String,
                      style: TextStyle(
                        color: isMe
                            ? AppColors.accentLight
                            : AppColors.textColor,
                        fontWeight: isMe
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    NumberFormatter.format(entry['capital'] as double),
                    style: TextStyle(
                      color: isMe
                          ? AppColors.accentLight
                          : AppColors.textColor.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
