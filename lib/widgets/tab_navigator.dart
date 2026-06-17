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
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final isSelected = i == currentTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => ref.read(gameProvider.notifier).setTab(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.accent, Color(0xFF0F6B50)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _tabs[i].$1,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _tabs[i].$2,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textColor.withOpacity(0.6),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
