import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/services/game_provider.dart';
import '../core/utils/number_formatter.dart';
import '../widgets/glass_container.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  String _pin = '';
  bool _unlocked = false;
  bool _error = false;
  static const _correctPin = '2233';

  void _onPin(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = false;
    });
    if (_pin.length == 4) {
      if (_pin == _correctPin) {
        setState(() => _unlocked = true);
        ref.read(gameProvider.notifier).unlockAdmin();
      } else {
        setState(() {
          _error = true;
          _pin = '';
        });
      }
    }
  }

  void _clearPin() => setState(() {
        _pin = '';
        _error = false;
      });

  @override
  Widget build(BuildContext context) {
    // If already unlocked in game state, auto-unlock
    final game = ref.read(gameProvider);
    if (game.adminUnlocked && !_unlocked) {
      _unlocked = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.textColor),
                  ),
                  const Text(
                    '⚙️ Админ Панель',
                    style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _unlocked ? _buildAdminPanel() : _buildPinPad(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinPad() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🔐',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            'Введите PIN-код',
            style: TextStyle(
                color: AppColors.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _error
                      ? const Color(0xFFE74C3C)
                      : filled
                          ? AppColors.accent
                          : AppColors.glass,
                  border: Border.all(
                      color: _error
                          ? const Color(0xFFE74C3C)
                          : AppColors.glassBorder),
                ),
              );
            }),
          ),
          if (_error) ...[
            const SizedBox(height: 12),
            const Text(
              'Неверный PIN-код',
              style: TextStyle(color: Color(0xFFE74C3C), fontSize: 14),
            ),
          ],
          const SizedBox(height: 32),
          // Numpad
          ...([
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['⌫', '0', '✓'],
          ].map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((d) {
                    if (d == '✓') return const SizedBox(width: 80, height: 60);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: d == '⌫'
                            ? _clearPin
                            : () => _onPin(d),
                        child: Container(
                          width: 70,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.glass,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.glassBorder),
                          ),
                          child: Center(
                            child: Text(
                              d,
                              style: const TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ))),
        ],
      ),
    );
  }

  Widget _buildAdminPanel() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassContainer(
          color: AppColors.accent.withOpacity(0.06),
          borderColor: AppColors.accent.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✅ Доступ открыт',
                style: TextStyle(
                    color: AppColors.accentLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Режим разработчика активен',
                style: TextStyle(
                    color: AppColors.textColor.withOpacity(0.5),
                    fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Money buttons
        const Text(
          '💰 Добавить деньги',
          style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AdminButton(
                label: '+\$1M',
                icon: '💵',
                color: AppColors.accent,
                onTap: () => ref
                    .read(gameProvider.notifier)
                    .adminAddMoney(1000000),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AdminButton(
                label: '+\$1B',
                icon: '💎',
                color: AppColors.purple,
                onTap: () => ref
                    .read(gameProvider.notifier)
                    .adminAddMoney(1000000000),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Business actions
        const Text(
          '🏢 Бизнесы',
          style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AdminButton(
                label: 'Все менеджеры',
                icon: '🤖',
                color: const Color(0xFF3498DB),
                onTap: () =>
                    ref.read(gameProvider.notifier).adminAllManagers(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AdminButton(
                label: 'Макс бизнесы',
                icon: '🚀',
                color: const Color(0xFFE67E22),
                onTap: () =>
                    ref.read(gameProvider.notifier).adminMaxBusinesses(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        Center(
          child: Text(
            'FOR TESTING ONLY',
            style: TextStyle(
                color: AppColors.textColor.withOpacity(0.2),
                fontSize: 11,
                letterSpacing: 2),
          ),
        ),
      ],
    );
  }
}

class _AdminButton extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1)
          ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
