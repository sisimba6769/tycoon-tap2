import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/hive_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/game_provider.dart';
import 'core/theme.dart';
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

class _AppNavigatorState extends ConsumerState<AppNavigator> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadServerProgress();
  }

  Future<void> _loadServerProgress() async {
    final progress = await AuthService.loadProgress();
    if (progress != null && mounted) {
      ref.read(gameProvider.notifier).loadFromServer(Map<String, dynamic>.from(progress));
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💰', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: Color(0xFF1D9E75)),
              SizedBox(height: 16),
              Text('Загружаем прогресс...',
                  style: TextStyle(color: Color(0xFFF0F0F0), fontSize: 14)),
            ],
          ),
        ),
      );
    }
    return const MainScreen();
  }
}