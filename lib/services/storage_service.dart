import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crew.dart';

/// データ永続化サービス
class StorageService {
  static const String _crewsKey = 'mcdonaldsCrews';

  /// クルーデータを保存
  static Future<void> saveCrews(List<Crew> crews) async {
    final prefs = await SharedPreferences.getInstance();
    final crewsJson = crews.map((crew) => crew.toJson()).toList();
    await prefs.setString(_crewsKey, jsonEncode(crewsJson));
  }

  /// クルーデータを読み込み
  static Future<List<Crew>> loadCrews() async {
    final prefs = await SharedPreferences.getInstance();
    final crewsString = prefs.getString(_crewsKey);

    if (crewsString == null || crewsString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> crewsJson = jsonDecode(crewsString);
      return crewsJson.map((json) => Crew.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// すべてのデータをクリア
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_crewsKey);
  }
}
