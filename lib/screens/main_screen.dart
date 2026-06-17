import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/services/game_provider.dart';
import '../core/theme.dart';
import '../core/utils/number_formatter.dart';
import '../widgets/game_background.dart';
import '../widgets/glass_container.dart';
import '../widgets/tap_button.dart';
import '../widgets/news_ticker.dart';
import '../widgets/tab_navigator.dart';
import '../features/businesses/businesses_tab.dart';
import '../features/investments/investments_tab.dart';
import '../features/stocks/stocks_tab.dart';
import '../features/taxes/taxes_tab.dart';
import '../features/prestige/prestige_tab.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              _TopBar(),

              // Balance display
              _BalanceDisplay(),

              const SizedBox(height: 8),

              // News ticker
              const NewsTicker(),

              const SizedBox(height: 8),

              // Tap button (only show on businesses/main tab)
              if (game.currentTab == 0) ...[
                const TapButton(),
                const SizedBox(height: 4),
              ],

              // Tab navigator
              const TabNavigator(),

              // Tab content
              Expanded(
                child: _TabContent(tab: game.currentTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Logo/title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.accentLight, AppColors.purple],
            ).createShader(bounds),
            child: const Text(
              '💰 TycoonTap',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          // Admin button (small)
          GlassContainer(
            padding: const EdgeInsets.all(8),
            borderRadius: 12,
            onTap: () => context.push('/admin'),
            child: const Text('🔐', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          // Settings button
          GlassContainer(
            padding: const EdgeInsets.all(8),
            borderRadius: 12,
            onTap: () => context.push('/settings'),
            child: const Text('⚙️', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class _BalanceDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Main balance
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.accentLight, Color(0xFF7FE8C9)],
              ).createShader(bounds),
              child: Text(
                NumberFormatter.format(game.money),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormatter.formatPerSec(game.incomePerSecond),
                  style: TextStyle(
                    color: AppColors.accentLight.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '  ·  Всего: ${NumberFormatter.format(game.totalEarned)}',
                  style: TextStyle(
                    color: AppColors.textColor.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            // Prestige multiplier badge
            if (game.prestigeLevel > 0) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.purple.withOpacity(0.3)),
                ),
                child: Text(
                  '⭐ Престиж ${game.prestigeLevel} · ×${game.prestigeMultiplier.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final int tab;
  const _TabContent({required this.tab});

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case 0:
        return const BusinessesTab();
      case 1:
        return const InvestmentsTab();
      case 2:
        return const StocksTab();
      case 3:
        return const TaxesTab();
      case 4:
        return const PrestigeTab();
      default:
        return const BusinessesTab();
    }
  }
}
