import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/game_provider.dart';
import '../../core/models/game_models.dart';
import '../../core/theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../widgets/glass_container.dart';
 
class BusinessCard extends ConsumerStatefulWidget {
  final int index;
  const BusinessCard({super.key, required this.index});
 
  @override
  ConsumerState<BusinessCard> createState() => _BusinessCardState();
}
 
class _BusinessCardState extends ConsumerState<BusinessCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
 
  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final b = game.businesses[widget.index];
    final canAfford = game.money >= b.cost;
    final canAffordManager = b.owned > 0 && game.money >= b.managerCost;
    final income = b.income(game.prestigeMultiplier, game.newsMultiplier);
 
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      color: b.isStopped
          ? const Color(0xFFE74C3C).withOpacity(0.08)
          : b.owned > 0
              ? AppColors.accent.withOpacity(0.06)
              : AppColors.glass,
      borderColor: b.isStopped
          ? const Color(0xFFE74C3C).withOpacity(0.3)
          : b.owned > 0
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Center(child: Text(b.icon, style: const TextStyle(fontSize: 26))),
                  ),
                  if (b.owned > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('×${b.owned}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(b.name,
                              style: const TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        if (b.level > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.purple.withOpacity(0.5)),
                            ),
                            child: Text('Lv${b.level}',
                                style: const TextStyle(color: AppColors.purple, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (b.owned > 0)
                      Text('${NumberFormatter.format(income)}/${b.cycleTime.toStringAsFixed(0)}с',
                          style: const TextStyle(color: AppColors.accentLight, fontSize: 12))
                    else
                      Text('Стоимость: ${NumberFormatter.format(b.cost)}',
                          style: TextStyle(color: AppColors.textColor.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (b.owned > 0 && b.isRunning) ...[
            const SizedBox(height: 10),
            _ProgressBar(progress: b.progress),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: b.owned == 0 ? 'Купить' : '+ ещё ${NumberFormatter.format(b.cost)}',
                  enabled: canAfford,
                  onTap: () => ref.read(gameProvider.notifier).buyBusiness(widget.index),
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              if (b.owned > 0 && !b.hasManager) ...[
                _ActionButton(
                  label: b.isRunning ? '▶ Идёт' : '▶ Запуск',
                  enabled: !b.isRunning && !b.isStopped,
                  onTap: () => ref.read(gameProvider.notifier).runBusiness(widget.index),
                  color: const Color(0xFF3498DB),
                  small: true,
                ),
                const SizedBox(width: 8),
              ],
              if (b.owned > 0) ...[
                if (!b.hasManager)
                  _ActionButton(
                    label: '🤖',
                    enabled: canAffordManager,
                    onTap: () => ref.read(gameProvider.notifier).buyManager(widget.index),
                    color: AppColors.purple,
                    small: true,
                    tooltip: 'Менеджер: ${NumberFormatter.format(b.managerCost)}',
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.purple.withOpacity(0.4)),
                    ),
                    child: const Text('🤖 Авто',
                        style: TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textColor.withOpacity(0.7),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if (_expanded && b.owned > 0) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.glassBorder, height: 1),
            const SizedBox(height: 10),
            _UpgradesRow(businessIndex: widget.index),
          ],
        ],
      ),
    );
  }
}
 
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(color: AppColors.glass, borderRadius: BorderRadius.circular(3)),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.accentLight, AppColors.accent]),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.5), blurRadius: 4)],
          ),
        ),
      ),
    );
  }
}
 
class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final Color color;
  final bool small;
  final String? tooltip;
 
  const _ActionButton({
    required this.label,
    required this.enabled,
    this.onTap,
    required this.color,
    this.small = false,
    this.tooltip,
  });
 
  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: small ? 10 : 14, vertical: small ? 6 : 8),
        decoration: BoxDecoration(
          gradient: enabled ? LinearGradient(colors: [color, color.withOpacity(0.7)]) : null,
          color: enabled ? null : AppColors.glass,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: enabled ? color.withOpacity(0.6) : AppColors.glassBorder),
          boxShadow: enabled ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? Colors.white : AppColors.textColor.withOpacity(0.4),
            fontSize: small ? 11 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: child);
    return child;
  }
}
 
class _UpgradesRow extends ConsumerWidget {
  final int businessIndex;
  const _UpgradesRow({required this.businessIndex});
 
  static const _upgradeLabels = ['×2', '×5', '×10'];
  static const _upgradeColors = [
    Color(0xFF3498DB),
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
  ];
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final b = game.businesses[businessIndex];
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Улучшения',
            style: TextStyle(color: AppColors.textColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (i) {
            final bought = b.upgrades[i];
            final cost = b.upgradeCost(i);
            final canAfford = game.money >= cost;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                child: GestureDetector(
                  onTap: bought || !canAfford
                      ? null
                      : () => ref.read(gameProvider.notifier).buyUpgrade(businessIndex, i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: bought
                          ? _upgradeColors[i].withOpacity(0.2)
                          : canAfford
                              ? _upgradeColors[i].withOpacity(0.1)
                              : AppColors.glass,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: bought
                            ? _upgradeColors[i]
                            : canAfford
                                ? _upgradeColors[i].withOpacity(0.4)
                                : AppColors.glassBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (bought) const Icon(Icons.check, color: Colors.white, size: 12),
                            Text(_upgradeLabels[i],
                                style: TextStyle(
                                    color: bought ? Colors.white : _upgradeColors[i],
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (!bought)
                          Text(
                            NumberFormatter.format(cost),
                            style: TextStyle(
                                color: canAfford ? _upgradeColors[i] : AppColors.textColor.withOpacity(0.4),
                                fontSize: 9),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (b.level < 4) ...[
          const SizedBox(height: 8),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => ref.read(gameProvider.notifier).upgradeBusiness(businessIndex),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.purple.withOpacity(0.4)),
              ),
              child: Text(
                'Уровень ${b.level} → ${b.level + 1}: ${NumberFormatter.format(b.cost * 100 * b.level)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.purple, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }