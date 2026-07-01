import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/hive_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/game_provider.dart';
import 'core/theme.dart';
import 'core/utils/number_formatter.dart';
import 'widgets/glass_container.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await HiveService.init();
  runApp(const ProviderScope(child: TycoonTapApp()));
}

class TycoonTapApp extends ConsumerWidget {
  const TycoonTapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    AppColors.isDark = isDark;
    return MaterialApp(
      title: 'TycoonTap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AuthService.isLoggedIn ? const AppNavigator() : const _AuthWrapper(),
      routes: {
        '/settings': (_) => const SettingsScreen(),
        '/admin': (_) => const AdminScreen(),
      },
    );
  }
}

class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  bool _authed = false;

  @override
  Widget build(BuildContext context) {
    if (_authed) return const AppNavigator();
    return AuthScreen(
      onSuccess: () async {
        setState(() => _authed = true);
      },
    );
  }
}

class AppNavigator extends ConsumerStatefulWidget {
  const AppNavigator({super.key});

  @override
  ConsumerState<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends ConsumerState<AppNavigator> with WidgetsBindingObserver {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadServerProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final notifier = ref.read(gameProvider.notifier);
    if (lifecycle == AppLifecycleState.resumed) {
      notifier.resumeGame();
      _maybeShowOfflineEarnings();
    } else if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.detached) {
      notifier.pauseGame();
    }
  }

  Future<void> _loadServerProgress() async {
    final progress = await AuthService.loadProgress();
    if (progress != null && mounted) {
      ref.read(gameProvider.notifier).loadFromServer(Map<String, dynamic>.from(progress));
    }
    // Apply offline earnings AFTER server progress is loaded, so they are not
    // overwritten by the server snapshot.
    ref.read(gameProvider.notifier).applyOfflineProgress();
    if (mounted) setState(() => _loaded = true);
    _maybeShowOfflineEarnings();
  }

  /// Shows a "while you were away" popup if offline earnings were credited.
  void _maybeShowOfflineEarnings() {
    final notifier = ref.read(gameProvider.notifier);
    final earned = notifier.lastOfflineEarned;
    if (earned <= 0) return;
    notifier.lastOfflineEarned = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👋', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 12),
                Text('С возвращением!',
                    style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Пока вас не было, менеджеры заработали:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textColor.withOpacity(0.7),
                        fontSize: 13)),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accentLight, Color(0xFF7FE8C9)],
                  ).createShader(bounds),
                  child: Text('+${NumberFormatter.format(earned)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppColors.accent, Color(0xFF0F6B50)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('Забрать 🎉',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0A0F), Color(0xFF12121F)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏙️', style: TextStyle(fontSize: 84)),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accentLight, Color(0xFF7FE8C9)],
                  ).createShader(bounds),
                  child: const Text('TycoonTap',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ),
                const SizedBox(height: 8),
                Text('Построй свою бизнес-империю',
                    style: TextStyle(
                        color: const Color(0xFFF0F0F0).withOpacity(0.6),
                        fontSize: 13)),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                      color: AppColors.accent, strokeWidth: 2.6),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const MainScreen();
  }
}