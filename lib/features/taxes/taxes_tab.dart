import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/game_provider.dart';
import '../../core/theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../widgets/glass_container.dart';

class TaxesTab extends ConsumerWidget {
  const TaxesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final totalDebt = game.businesses.fold(0.0, (s, b) => s + b.taxDebt);
    final canPayAll = game.money >= totalDebt && totalDebt > 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              '🧾 Налоги',
              style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFF39C12).withOpacity(0.3)),
              ),
              child: Text(
                'Ставка: ${(game.taxRate * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFFF39C12),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Не плати вовремя — бизнес остановят',
          style: TextStyle(
              color: AppColors.textColor.withOpacity(0.5), fontSize: 12),
        ),
        const SizedBox(height: 12),
        // Total debt summary
        GlassContainer(
          padding: const EdgeInsets.all(14),
          color: totalDebt > 0
              ? const Color(0xFFE74C3C).withOpacity(0.06)
              : AppColors.accent.withOpacity(0.06),
          borderColor: totalDebt > 0
              ? const Color(0xFFE74C3C).withOpacity(0.25)
              : AppColors.accent.withOpacity(0.25),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Общий долг',
                    style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.6),
                        fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormatter.format(totalDebt),
                    style: TextStyle(
                      color: totalDebt > 0
                          ? const Color(0xFFE74C3C)
                          : AppColors.accentLight,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (totalDebt > 0)
                GestureDetector(
                  onTap: canPayAll
                      ? () => ref.read(gameProvider.notifier).payAllTaxes()
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: canPayAll
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFE74C3C),
                                Color(0xFFC0392B)
                              ],
                            )
                          : null,
                      color: canPayAll ? null : AppColors.glass,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: canPayAll
                              ? const Color(0xFFE74C3C).withOpacity(0.5)
                              : AppColors.glassBorder),
                    ),
                    child: Text(
                      'Оплатить всё',
                      style: TextStyle(
                        color: canPayAll
                            ? Colors.white
                            : AppColors.textColor.withOpacity(0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Per-business tax rows
        ...List.generate(game.businesses.length, (i) {
          final b = game.businesses[i];
          if (b.owned == 0) return const SizedBox.shrink();
          final status = b.isStopped
              ? ('⛔ Остановлен', const Color(0xFFE74C3C))
              : b.taxDebt > 0
                  ? ('⚠️ Долг', const Color(0xFFF39C12))
                  : ('✅ Оплачено', AppColors.accentLight);
          final canPay = game.money >= b.taxDebt && b.taxDebt > 0;

          return GlassContainer(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(b.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      Row(
                        children: [
                          Text(
                            status.$1,
                            style: TextStyle(
                                color: status.$2, fontSize: 11),
                          ),
                          if (b.taxDebt > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              NumberFormatter.format(b.taxDebt),
                              style: const TextStyle(
                                  color: Color(0xFFE74C3C), fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (b.taxDebt > 0)
                  GestureDetector(
                    onTap: canPay
                        ? () => ref.read(gameProvider.notifier).payTax(i)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: canPay
                            ? const LinearGradient(colors: [
                                Color(0xFFF39C12),
                                Color(0xFFE67E22)
                              ])
                            : null,
                        color: canPay ? null : AppColors.glass,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: canPay
                                ? const Color(0xFFF39C12).withOpacity(0.5)
                                : AppColors.glassBorder),
                      ),
                      child: Text(
                        'Оплатить',
                        style: TextStyle(
                          color: canPay
                              ? Colors.white
                              : AppColors.textColor.withOpacity(0.3),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
