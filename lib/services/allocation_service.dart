import '../models/crew.dart';
import '../models/position.dart';
import '../models/allocation_result.dart';

/// 配置計算サービス (11ポジション対応)
class AllocationService {
  /// 最適配置を計算
  static AllocationResult calculateOptimalAllocation(
    List<Crew> crews,
    int totalStaff,
    int targetSales,
  ) {
    // 重要度順にポジションを取得
    final positions = Position.getSortedByPriority();
    
    // クルーを総合スキルの高い順にソート
    final availableCrews = List<Crew>.from(crews)
      ..sort((a, b) => b.totalSkill.compareTo(a.totalSkill));

    // 配置結果を初期化
    final assignments = <PositionAssignment>[];
    final assignedCrewIds = <int>{};

    // 各ポジションに対して最適なクルーを配置
    for (final position in positions) {
      Crew? bestCrew;
      int bestScore = 0;

      // 未配置のクルーから最適な候補を探す
      for (final crew in availableCrews) {
        if (assignedCrewIds.contains(crew.id)) continue;

        final score = position.getMatchScore(
          crew.counterSkill,
          crew.kitchenSkill,
          crew.hasLicense,
          crew.potatoOk,
        );

        if (score > bestScore) {
          bestScore = score;
          bestCrew = crew;
        }
      }

      // 配置を記録
      if (bestCrew != null && bestScore > 0) {
        assignments.add(PositionAssignment(
          position: position,
          assignedCrew: bestCrew,
        ));
        assignedCrewIds.add(bestCrew.id);
      } else {
        // 適切なクルーが見つからない場合は未配置
        assignments.add(PositionAssignment(position: position));
      }
    }

    // 未配置クルーのリスト
    final unassigned = availableCrews
        .where((crew) => !assignedCrewIds.contains(crew.id))
        .toList();

    return AllocationResult(
      assignments: assignments,
      unassigned: unassigned,
    );
  }

  /// 配置の詳細情報を取得
  static Map<String, dynamic> getDetailedStats(AllocationResult result) {
    final kitchenPositions = result.assignments
        .where((a) => a.position.requiredSkillType == 'kitchen' && a.isAssigned)
        .length;

    final counterPositions = result.assignments
        .where((a) => a.position.requiredSkillType == 'counter' && a.isAssigned)
        .length;

    final bothPositions = result.assignments
        .where((a) => a.position.requiredSkillType == 'both' && a.isAssigned)
        .length;

    final avgSkill = result.assignedCrews.isEmpty
        ? 0.0
        : result.assignedCrews
                .map((c) => c.totalSkill)
                .reduce((a, b) => a + b) /
            result.assignedCrews.length;

    return {
      'totalAssigned': result.totalAssigned,
      'kitchenPositions': kitchenPositions,
      'counterPositions': counterPositions,
      'bothPositions': bothPositions,
      'unassignedCount': result.unassigned.length,
      'averageSkill': avgSkill.toStringAsFixed(1),
    };
  }
}
