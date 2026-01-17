import 'crew.dart';

/// 配置結果を管理するモデル
class AllocationResult {
  final List<Crew> riders; // ライダー
  final List<Crew> potato; // ポテト担当
  final List<Crew> kitchen; // 厨房
  final List<Crew> counter; // カウンター
  final List<Crew> drive; // ドライブスルー
  final List<Crew> outside; // 外キャッシャー
  final List<Crew> hot; // ホット

  AllocationResult({
    required this.riders,
    required this.potato,
    required this.kitchen,
    required this.counter,
    required this.drive,
    required this.outside,
    required this.hot,
  });

  /// 配置済みクルー総数
  int get totalAllocated =>
      riders.length +
      potato.length +
      kitchen.length +
      counter.length +
      drive.length +
      outside.length +
      hot.length;

  /// 空の配置結果を作成
  factory AllocationResult.empty() {
    return AllocationResult(
      riders: [],
      potato: [],
      kitchen: [],
      counter: [],
      drive: [],
      outside: [],
      hot: [],
    );
  }
}
