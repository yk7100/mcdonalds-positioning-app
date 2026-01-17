import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/allocation_rating.dart';

/// 評価データと学習データを管理するサービス（localStorage使用）
class RatingService {
  static const String _ratingsKey = 'allocation_ratings';
  static const String _learningDataKey = 'learning_data';

  /// 評価を保存
  static Future<void> saveRating(AllocationRating rating) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 既存の評価リストを取得
    final ratings = await getAllRatings();
    ratings.add(rating);
    
    // JSON文字列リストに変換して保存
    final jsonList = ratings.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_ratingsKey, jsonList);
    
    // 学習データを更新
    await _updateLearningData(rating);
  }

  /// すべての評価を取得
  static Future<List<AllocationRating>> getAllRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_ratingsKey) ?? [];
    
    return jsonList
        .map((jsonStr) => AllocationRating.fromJson(jsonDecode(jsonStr)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 新しい順
  }

  /// 最近の評価を取得（件数指定）
  static Future<List<AllocationRating>> getRecentRatings(int count) async {
    final allRatings = await getAllRatings();
    return allRatings.take(count).toList();
  }

  /// 学習データを更新
  static Future<void> _updateLearningData(AllocationRating rating) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 既存の学習データを取得
    final learningDataMap = await _getLearningDataMap();
    
    // 各配置について学習データを更新
    for (final assignment in rating.assignments) {
      final key = assignment.key;
      
      final currentData = learningDataMap[key] ??
          LearningData.initial(assignment.crewName, assignment.positionId);
      
      // 評価を追加
      learningDataMap[key] = currentData.addRating(rating.rating);
    }
    
    // 保存
    final jsonMap = learningDataMap.map(
      (key, data) => MapEntry(key, jsonEncode(data.toJson())),
    );
    await prefs.setString(_learningDataKey, jsonEncode(jsonMap));
  }

  /// 学習データマップを取得
  static Future<Map<String, LearningData>> _getLearningDataMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_learningDataKey);
    
    if (jsonStr == null) return {};
    
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    return jsonMap.map(
      (key, value) => MapEntry(
        key,
        LearningData.fromJson(jsonDecode(value as String)),
      ),
    );
  }

  /// クルー×ポジションの学習データを取得
  static Future<LearningData?> getLearningData(
    String crewName,
    String positionId,
  ) async {
    final learningDataMap = await _getLearningDataMap();
    return learningDataMap['${crewName}_$positionId'];
  }

  /// すべての学習データを取得
  static Future<List<LearningData>> getAllLearningData() async {
    final learningDataMap = await _getLearningDataMap();
    return learningDataMap.values.toList()
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore)); // スコア順
  }

  /// 統計情報を取得
  static Future<Map<String, dynamic>> getStatistics() async {
    final ratings = await getAllRatings();
    
    if (ratings.isEmpty) {
      return {
        'totalRatings': 0,
        'averageRating': 0.0,
        'bestRating': null,
        'recentTrend': [],
      };
    }
    
    final totalRatings = ratings.length;
    final averageRating = ratings
        .map((r) => r.rating)
        .reduce((a, b) => a + b) / totalRatings;
    
    // 最高評価の配置
    final bestRating = ratings.reduce(
      (a, b) => a.rating > b.rating ? a : b,
    );
    
    // 最近5件のトレンド
    final recentTrend = ratings
        .take(5)
        .map((r) => {'date': r.date, 'rating': r.rating})
        .toList();
    
    return {
      'totalRatings': totalRatings,
      'averageRating': averageRating,
      'bestRating': bestRating,
      'recentTrend': recentTrend,
    };
  }

  /// すべてのデータをクリア（デバッグ用）
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ratingsKey);
    await prefs.remove(_learningDataKey);
  }
}
