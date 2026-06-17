import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/theme.dart';
import '../core/services/audio_service.dart';
import '../core/services/game_provider.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final audio = ref.read(audioServiceProvider);
    final soundEnabled = audio.soundEnabled;
    final volume = audio.volume;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: SafeArea(
            child: Column(
              children: [
                // Header
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
                        'Настройки',
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Theme section
                      GlassContainer(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🎨 Оформление',
                              style: TextStyle(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _ThemeButton(
                                    label: '🌙 Тёмная',
                                    selected: isDark,
                                    onTap: () {
                                      ref
                                          .read(themeProvider.notifier)
                                          .state = true;
                                      Hive.box('settings').put('darkTheme', true);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _ThemeButton(
                                    label: '☀️ Светлая',
                                    selected: !isDark,
                                    onTap: () {
                                      ref
                                          .read(themeProvider.notifier)
                                          .state = false;
                                      Hive.box('settings').put('darkTheme', false);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Sound section
                      GlassContainer(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🔊 Звук',
                              style: TextStyle(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Звуки',
                                  style: TextStyle(
                                      color: AppColors.textColor.withOpacity(0.7),
                                      fontSize: 13),
                                ),
                                const Spacer(),
                                Switch(
                                  value: soundEnabled,
                                  onChanged: (v) {
                                    ref.read(audioServiceProvider).setSoundEnabled(v);
                                    setState(() {});
                                  },
                                  activeColor: AppColors.accent,
                                ),
                              ],
                            ),
                            if (soundEnabled) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Громкость',
                                    style: TextStyle(
                                        color: AppColors.textColor.withOpacity(0.7),
                                        fontSize: 13),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: volume,
                                      min: 0,
                                      max: 1,
                                      activeColor: AppColors.accent,
                                      onChanged: (v) {
                                        ref
                                            .read(audioServiceProvider)
                                            .setVolume(v);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Text(
                                    '${(volume * 100).toInt()}%',
                                    style: const TextStyle(
                                        color: AppColors.accentLight,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Danger zone
                      GlassContainer(
                        color: const Color(0xFFE74C3C).withOpacity(0.06),
                        borderColor: const Color(0xFFE74C3C).withOpacity(0.25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚠️ Опасная зона',
                              style: TextStyle(
                                  color: Color(0xFFE74C3C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () => _confirmReset(context, ref),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFE74C3C)
                                            .withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                    color:
                                        const Color(0xFFE74C3C).withOpacity(0.1),
                                  ),
                                  child: const Text(
                                    '🔄 Сбросить игру',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFE74C3C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Version
                      Center(
                        child: Text(
                          'TycoonTap v1.0.0',
                          style: TextStyle(
                              color: AppColors.textColor.withOpacity(0.3),
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Сброс игры',
            style: TextStyle(color: AppColors.textColor)),
        content: const Text(
          'Вся игра будет сброшена до начального состояния. Это действие нельзя отменить!',
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
              ref.read(gameProvider.notifier).resetGame();
              Navigator.pop(context);
            },
            child: const Text('Сбросить',
                style: TextStyle(
                    color: Color(0xFFE74C3C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppColors.accent, Color(0xFF0F6B50)])
              : null,
          color: selected ? null : AppColors.glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected
                  ? AppColors.accent.withOpacity(0.5)
                  : AppColors.glassBorder),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textColor.withOpacity(0.6),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
