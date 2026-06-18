import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';

class UpdateChecker {
  static const _versionUrl =
      'https://raw.githubusercontent.com/sisimba6769/tycoon-tap2/refs/heads/main/version.json';
  static const _currentVersion = '1.0.0';

  static Future<void> check(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(_versionUrl));
      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body);
      final latestVersion = data['version'] as String;
      final downloadUrl = data['download_url'] as String;
      if (latestVersion != _currentVersion) {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion, downloadUrl);
        }
      }
    } catch (_) {}
  }

  static void _showUpdateDialog(BuildContext context, String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F0F1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🚀 ', style: TextStyle(fontSize: 24)),
            Text('Доступно обновление!',
                style: TextStyle(color: Color(0xFFF0F0F0), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Версия $version уже доступна.',
                style: const TextStyle(color: Color(0xFFB0B0C0))),
            const SizedBox(height: 8),
            const Text('Скачай и установи новую версию чтобы получить улучшения!',
                style: TextStyle(color: Color(0xFFB0B0C0), fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Позже', style: TextStyle(color: Color(0xFFB0B0C0))),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1D9E75), Color(0xFF0F6B50)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('⬇️ Обновить',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
