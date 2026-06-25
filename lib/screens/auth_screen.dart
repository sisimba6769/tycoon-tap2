import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/theme.dart';
import '../core/services/auth_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/game_background.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const AuthScreen({super.key, required this.onSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = false;
  bool _loading = false;
  String _error = '';
  int _step = 0;

  void _next() async {
    if (_step == 0) {
      final name = _usernameController.text.trim();
      if (name.isEmpty) {
        setState(() => _error = 'Введи своё имя!');
        return;
      }
      setState(() { _step = 1; _error = ''; });
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Введи пароль!');
      return;
    }

    setState(() { _loading = true; _error = ''; });

    Map<String, dynamic> result;
    if (_isLogin) {
      result = await AuthService.login(username, password);
    } else {
      result = await AuthService.register(username, password);
    }

    setState(() => _loading = false);

    if (result.containsKey('error')) {
      setState(() => _error = result['error'].toString());
      return;
    }

    final box = Hive.box('settings');
    box.put('userId', result['userId']);
    box.put('username', username);

    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.accentLight, AppColors.purple],
                    ).createShader(bounds),
                    child: const Text(
                      'TycoonTap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _step == 0
                              ? (_isLogin ? 'Добро пожаловать!' : 'Как тебя зовут?')
                              : (_isLogin ? 'Введи пароль' : 'Придумай пароль'),
                          style: const TextStyle(
                            color: AppColors.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _step == 0
                              ? 'Это будет твоё имя в игре'
                              : (_isLogin ? 'Чтобы войти в аккаунт' : 'Запомни его — он нужен для входа'),
                          style: TextStyle(
                            color: AppColors.textColor.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_step == 0)
                          _buildInput(
                            controller: _usernameController,
                            hint: 'Твоё имя',
                            icon: Icons.person,
                          ),
                        if (_step == 1) ...[
                          GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: AppColors.accent, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _usernameController.text,
                                  style: const TextStyle(
                                    color: AppColors.accentLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInput(
                            controller: _passwordController,
                            hint: 'Пароль',
                            icon: Icons.lock,
                            obscure: true,
                          ),
                        ],
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error,
                            style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 13),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _loading ? null : _next,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.accent, Color(0xFF0F6B50)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: _loading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _step == 0 ? 'Далее →' : (_isLogin ? 'Войти' : 'Начать игру!'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isLogin = !_isLogin;
                              _step = 0;
                              _error = '';
                              _passwordController.clear();
                            }),
                            child: Text(
                              _isLogin ? 'Нет аккаунта? Зарегистрироваться' : 'Уже есть аккаунт? Войти',
                              style: TextStyle(
                                color: AppColors.accentLight.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textColor.withOpacity(0.4)),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 18),
        filled: true,
        fillColor: AppColors.glass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
      onSubmitted: (_) => _next(),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
