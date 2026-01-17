import '../models/crew.dart';
import '../models/allocation_result.dart';

/// 配置計算サービス
class AllocationService {
  /// 最適配置を計算
  static AllocationResult calculateOptimalAllocation(
    List<Crew> crews,
    int totalStaff,
    int targetSales,
  ) {
    final potatoIndependent = targetSales >= 70000;
    final ridersCount = (totalStaff / 10).floor();
    final actualStaff = totalStaff - ridersCount - (potatoIndependent ? 1 : 0);

    // スキルの高い順にソート
    final availableCrews = List<Crew>.from(crews)
      ..sort((a, b) => b.totalSkill.compareTo(a.totalSkill));

    final result = AllocationResult.empty();

    // ライダー選定
    final riderCandidates =
        availableCrews.where((c) => c.hasLicense).toList();
    for (var i = 0; i < ridersCount && i < riderCandidates.length; i++) {
      result.riders.add(riderCandidates[i]);
    }

    // ポテト担当選定
    if (potatoIndependent) {
      final potatoCandidates = availableCrews
          .where((c) => c.potatoOk && !result.riders.contains(c))
          .toList()
        ..sort((a, b) => a.totalSkill.compareTo(b.totalSkill));

      if (potatoCandidates.isNotEmpty) {
        result.potato.add(potatoCandidates.first);
      }
    }

    // 残りのクルー
    final remainingCrews = availableCrews
        .where((c) => !result.riders.contains(c) && !result.potato.contains(c))
        .toList();

    // 基本配置
    final basicAllocation = _getBasicAllocation(actualStaff);
    var crewIndex = 0;

    // 厨房配置
    for (var i = 0;
        i < basicAllocation['kitchen']! && crewIndex < remainingCrews.length;
        i++) {
      result.kitchen.add(remainingCrews[crewIndex++]);
    }

    // カウンター配置
    for (var i = 0;
        i < basicAllocation['counter']! && crewIndex < remainingCrews.length;
        i++) {
      result.counter.add(remainingCrews[crewIndex++]);
    }

    // ドライブスルー配置
    for (var i = 0;
        i < basicAllocation['drive']! && crewIndex < remainingCrews.length;
        i++) {
      result.drive.add(remainingCrews[crewIndex++]);
    }

    // 外キャッシャー配置
    for (var i = 0;
        i < basicAllocation['outside']! && crewIndex < remainingCrews.length;
        i++) {
      result.outside.add(remainingCrews[crewIndex++]);
    }

    // ホット配置
    for (var i = 0;
        i < basicAllocation['hot']! && crewIndex < remainingCrews.length;
        i++) {
      result.hot.add(remainingCrews[crewIndex++]);
    }

    return result;
  }

  /// 人数に応じた基本配置パターン
  static Map<String, int> _getBasicAllocation(int staffCount) {
    const allocations = {
      2: {'kitchen': 1, 'counter': 1, 'drive': 0, 'outside': 0, 'hot': 0},
      3: {'kitchen': 1, 'counter': 1, 'drive': 1, 'outside': 0, 'hot': 0},
      4: {'kitchen': 1, 'counter': 2, 'drive': 1, 'outside': 0, 'hot': 0},
      5: {'kitchen': 2, 'counter': 2, 'drive': 1, 'outside': 0, 'hot': 0},
      6: {'kitchen': 2, 'counter': 2, 'drive': 2, 'outside': 0, 'hot': 0},
      7: {'kitchen': 2, 'counter': 3, 'drive': 2, 'outside': 0, 'hot': 0},
      8: {'kitchen': 3, 'counter': 3, 'drive': 2, 'outside': 0, 'hot': 0},
      9: {'kitchen': 3, 'counter': 4, 'drive': 2, 'outside': 0, 'hot': 0},
      10: {'kitchen': 4, 'counter': 4, 'drive': 2, 'outside': 0, 'hot': 0},
      11: {'kitchen': 4, 'counter': 5, 'drive': 2, 'outside': 0, 'hot': 0},
      12: {'kitchen': 4, 'counter': 5, 'drive': 3, 'outside': 0, 'hot': 0},
      13: {'kitchen': 5, 'counter': 5, 'drive': 3, 'outside': 0, 'hot': 0},
      14: {'kitchen': 5, 'counter': 6, 'drive': 3, 'outside': 0, 'hot': 0},
      15: {'kitchen': 6, 'counter': 6, 'drive': 3, 'outside': 0, 'hot': 0},
      16: {'kitchen': 7, 'counter': 6, 'drive': 3, 'outside': 0, 'hot': 0},
      17: {'kitchen': 7, 'counter': 6, 'drive': 3, 'outside': 1, 'hot': 0},
      18: {'kitchen': 7, 'counter': 6, 'drive': 3, 'outside': 1, 'hot': 1},
      19: {'kitchen': 8, 'counter': 6, 'drive': 3, 'outside': 1, 'hot': 1},
      20: {'kitchen': 9, 'counter': 6, 'drive': 3, 'outside': 1, 'hot': 1},
    };

    return allocations[staffCount] ?? allocations[10]!;
  }
}
