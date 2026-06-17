import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('game');
    await Hive.openBox('settings');
    await Hive.openBox('stocks');
    await Hive.openBox('taxes');
  }

  static Box get gameBox => Hive.box('game');
  static Box get settingsBox => Hive.box('settings');
  static Box get stocksBox => Hive.box('stocks');
  static Box get taxesBox => Hive.box('taxes');
}
