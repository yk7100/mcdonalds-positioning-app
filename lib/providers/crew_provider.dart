import 'package:flutter/foundation.dart';
import '../models/crew.dart';
import '../services/storage_service.dart';

/// クルーデータを管理するProvider
class CrewProvider extends ChangeNotifier {
  List<Crew> _crews = [];

  List<Crew> get crews => _crews;

  /// 初期化 - データ読み込み
  Future<void> initialize() async {
    _crews = await StorageService.loadCrews();
    notifyListeners();
  }

  /// クルーを追加
  Future<void> addCrew(Crew crew) async {
    _crews.add(crew);
    await StorageService.saveCrews(_crews);
    notifyListeners();
  }

  /// クルーを削除
  Future<void> deleteCrew(int id) async {
    _crews.removeWhere((crew) => crew.id == id);
    await StorageService.saveCrews(_crews);
    notifyListeners();
  }

  /// すべてのデータをクリア
  Future<void> clearAll() async {
    _crews.clear();
    await StorageService.clearAllData();
    notifyListeners();
  }
}
