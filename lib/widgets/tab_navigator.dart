import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/game_provider.dart';
import '../core/theme.dart';
import '../widgets/glass_container.dart';

class TabNavigator extends ConsumerWidget {
  const TabNavigator({super.key});

  static const _tabs = [
    ('🏢', 'Бизнесы'),
    ('📈', 'Инвест'),
    ('📊', 'Акции'),
    ('🧾', 'Налоги'),
    ('⭐', 'Престиж'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final currentTab = game.currentTab;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        padding: const EdgeInsets.all(4),
        borderRadius: 20,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final n = _tabs.length;
            return Stack(
              children: [
                // Green highlight that fills the selected tab left-to-right.
                Positioned.fill(
                  child: Row(
                    children: List.generate(n, (i) {
                      if (i != currentTab) {
                        return const Expanded(child: SizedBox());
                      }
                      return Expanded(
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey<int>(currentTab),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          builder: (context, t, _) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: t,
                                heightFactor: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.accent,
                                        Color(0xFF0F6B50)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.accent.withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ),
                Row(
                  children: List.generate(n, (i) {
                    final isSelected = i == currentTab;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => ref.read(gameProvider.notifier).setTab(i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutBack,
                                scale: isSelected ? 1.2 : 1.0,
                                child: Text(
                                  _tabs[i].$1,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textColor.withOpacity(0.6),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                child: Text(_tabs[i].$2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
