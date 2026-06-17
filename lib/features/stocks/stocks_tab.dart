import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/game_provider.dart';
import '../../core/models/game_models.dart';
import '../../core/theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../widgets/glass_container.dart';

class StocksTab extends ConsumerWidget {
  const StocksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final ownedStocks = game.stocks.where((s) => s.ownedShares > 0).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '📊 Биржа',
          style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Торгуй акциями в реальном времени',
          style:
              TextStyle(color: AppColors.textColor.withOpacity(0.5), fontSize: 12),
        ),
        // Portfolio summary
        if (ownedStocks.isNotEmpty) ...[
          const SizedBox(height: 12),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            color: AppColors.purple.withOpacity(0.06),
            borderColor: AppColors.purple.withOpacity(0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💼 Мой портфель',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ...ownedStocks.map((s) {
                  final pnl = s.profitLoss;
                  final pnlColor =
                      pnl >= 0 ? AppColors.accentLight : const Color(0xFFE74C3C);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(s.ticker,
                            style: const TextStyle(
                                color: AppColors.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(width: 8),
                        Text(
                            '×${s.ownedShares} @ \$${s.currentPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: AppColors.textColor.withOpacity(0.6),
                                fontSize: 12)),
                        const Spacer(),
                        Text(
                          '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: pnlColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...game.stocks.map((s) => _StockCard(stock: s)),
      ],
    );
  }
}

class _StockCard extends ConsumerStatefulWidget {
  final StockData stock;
  const _StockCard({required this.stock});

  @override
  ConsumerState<_StockCard> createState() => _StockCardState();
}

class _StockCardState extends ConsumerState<_StockCard> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    // Get fresh stock from state
    final s = game.stocks.firstWhere((st) => st.ticker == widget.stock.ticker);
    final isUp = s.history.length >= 2
        ? s.currentPrice >= s.history[s.history.length - 2]
        : true;
    final priceColor =
        isUp ? AppColors.accentLight : const Color(0xFFE74C3C);
    final canBuy = game.money >= s.currentPrice * _qty;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.ticker,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    s.companyName,
                    style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.55),
                        fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        isUp ? Icons.trending_up : Icons.trending_down,
                        color: priceColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${s.currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: priceColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  if (s.dividendYield > 0)
                    Text(
                      'Дивид: ${(s.dividendYield * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                          color: AppColors.accentLight.withOpacity(0.7),
                          fontSize: 10),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mini chart
          if (s.history.length > 2)
            SizedBox(
              height: 50,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        s.history.length,
                        (i) => FlSpot(i.toDouble(), s.history[i]),
                      ),
                      isCurved: true,
                      color: priceColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: priceColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          // Owned info
          if (s.ownedShares > 0) ...[
            Row(
              children: [
                Text(
                  'В портфеле: ${s.ownedShares} шт.',
                  style: TextStyle(
                      color: AppColors.textColor.withOpacity(0.7), fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ср. цена: \$${s.avgBuyPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: AppColors.textColor.withOpacity(0.5), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // Qty selector + buy/sell
          Row(
            children: [
              // Qty stepper
              GlassContainer(
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                      icon: const Icon(Icons.remove, size: 16),
                      color: AppColors.textColor,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                    ),
                    Text(
                      '$_qty',
                      style: const TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _qty++),
                      icon: const Icon(Icons.add, size: 16),
                      color: AppColors.textColor,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Buy button
              Expanded(
                child: GestureDetector(
                  onTap: canBuy
                      ? () => ref
                          .read(gameProvider.notifier)
                          .buyStock(s.ticker, _qty)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: canBuy
                          ? const LinearGradient(
                              colors: [AppColors.accent, Color(0xFF0F6B50)])
                          : null,
                      color: canBuy ? null : AppColors.glass,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: canBuy
                              ? AppColors.accent.withOpacity(0.5)
                              : AppColors.glassBorder),
                    ),
                    child: Text(
                      'Купить\n${NumberFormatter.format(s.currentPrice * _qty)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: canBuy
                            ? Colors.white
                            : AppColors.textColor.withOpacity(0.3),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sell button
              Expanded(
                child: GestureDetector(
                  onTap: s.ownedShares >= _qty
                      ? () => ref
                          .read(gameProvider.notifier)
                          .sellStock(s.ticker, _qty)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: s.ownedShares >= _qty
                          ? const LinearGradient(
                              colors: [Color(0xFFE74C3C), Color(0xFFC0392B)])
                          : null,
                      color:
                          s.ownedShares >= _qty ? null : AppColors.glass,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: s.ownedShares >= _qty
                              ? const Color(0xFFE74C3C).withOpacity(0.5)
                              : AppColors.glassBorder),
                    ),
                    child: Text(
                      'Продать\n${NumberFormatter.format(s.currentPrice * _qty)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: s.ownedShares >= _qty
                            ? Colors.white
                            : AppColors.textColor.withOpacity(0.3),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
