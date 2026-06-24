import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  static const _baseUrl = 'http://2.26.49.29:3000';

  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Нет соединения с сервером'};
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Нет соединения с сервером'};
    }
  }

  static Future<void> saveProgress(Map<String, dynamic> data) async {
    final box = Hive.box('settings');
    final userId = box.get('userId');
    if (userId == null) return;
    try {
      await http.post(
        Uri.parse('$_baseUrl/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'data': data}),
      );
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadProgress() async {
    final box = Hive.box('settings');
    final userId = box.get('userId');
    if (userId == null) return null;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/load/$userId'));
      final data = jsonDecode(response.body);
      return data['data'];
    } catch (_) {
      return null;
    }
  }

  static bool get isLoggedIn => Hive.box('settings').get('userId') != null;
  static String get username => Hive.box('settings').get('username') ?? '';
  static int get userId => Hive.box('settings').get('userId') ?? 0;

  static void logout() {
    final box = Hive.box('settings');
    box.delete('userId');
    box.delete('username');
  }
}
