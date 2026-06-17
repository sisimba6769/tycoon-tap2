import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/game_provider.dart';
import '../../core/theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../widgets/glass_container.dart';

class InvestmentsTab extends ConsumerWidget {
  const InvestmentsTab({super.key});

  static const _riskColors = {
    'Low': Color(0xFF2ECC71),
    'Medium': Color(0xFFF39C12),
    'High': Color(0xFFE74C3C),
    'Legendary': Color(0xFF9B59B6),
  };

  static const _riskLabels = {
    'Low': '🟢 Низкий',
    'Medium': '🟡 Средний',
    'High': '🔴 Высокий',
    'Legendary': '🟣 Легендарный',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final investments = game.investments;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '📈 Инвестиции',
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Вложи деньги и испытай удачу',
          style: TextStyle(
              color: AppColors.textColor.withOpacity(0.5), fontSize: 12),
        ),
        const SizedBox(height: 12),
        ...investments.map((inv) {
          final riskColor = _riskColors[inv.risk] ?? AppColors.accent;
          final canAfford = game.money >= inv.cost;
          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            color: canAfford
                ? riskColor.withOpacity(0.05)
                : AppColors.glass,
            borderColor: canAfford
                ? riskColor.withOpacity(0.25)
                : AppColors.glassBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.name,
                            style: const TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            inv.description,
                            style: TextStyle(
                              color: AppColors.textColor.withOpacity(0.55),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: riskColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        _riskLabels[inv.risk] ?? inv.risk,
                        style: TextStyle(
                            color: riskColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatChip(
                      label: 'Стоимость',
                      value: NumberFormatter.format(inv.cost),
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Шанс',
                      value: '${(inv.chance * 100).toInt()}%',
                      color: riskColor,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Множитель',
                      value: '×${inv.multiplier}',
                      color: AppColors.accentLight,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Invest / Cooldown button
                SizedBox(
                  width: double.infinity,
                  child: inv.isOnCooldown
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.glass,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Перезарядка: ${inv.cooldownRemaining}с',
                                style: TextStyle(
                                  color: AppColors.textColor.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: canAfford
                              ? () => ref
                                  .read(gameProvider.notifier)
                                  .invest(investments.indexOf(inv))
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              gradient: canAfford
                                  ? LinearGradient(
                                      colors: [
                                        riskColor,
                                        riskColor.withOpacity(0.7)
                                      ],
                                    )
                                  : null,
                              color: canAfford ? null : AppColors.glass,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: canAfford
                                    ? riskColor.withOpacity(0.5)
                                    : AppColors.glassBorder,
                              ),
                            ),
                            child: Text(
                              canAfford
                                  ? 'Инвестировать ${NumberFormatter.format(inv.cost)}'
                                  : 'Недостаточно средств',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: canAfford
                                    ? Colors.white
                                    : AppColors.textColor.withOpacity(0.3),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: color.withOpacity(0.7), fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
