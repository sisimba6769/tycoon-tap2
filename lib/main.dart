import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/hive_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

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
      home: AuthService.isLoggedIn ? const MainScreen() : _AuthWrapper(),
    );
  }
}

class _AuthWrapper extends StatefulWidget {
  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  bool _authed = false;

  @override
  Widget build(BuildContext context) {
    if (_authed) return const MainScreen();
    return AuthScreen(
      onSuccess: () => setState(() => _authed = true),
    );
  }
}
