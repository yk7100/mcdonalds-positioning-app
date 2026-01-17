import '../models/crew.dart';
import '../models/position.dart';
import '../models/allocation_result.dart';

/// 配置計算サービス (11ポジション対応 - 重要度優先)
class AllocationService {
  /// 最適配置を計算（重要度優先アルゴリズム）
  static AllocationResult calculateOptimalAllocation(
    List<Crew> crews,
    int totalStaff,
    int targetSales,
  ) {
    // 重要度順にポジションを取得
    final positions = Position.getSortedByPriority();
    
    // 配置結果を初期化
    final assignments = <PositionAssignment>[];
    final assignedCrewIds = <int>{};
    final availableCrews = List<Crew>.from(crews);

    // フェーズ1: 重要度の高いポジションから順に最適なクルーを配置
    // まず厳格な基準で配置を試みる
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
          forceAssign: false, // 厳格基準
        );

        if (score > bestScore) {
          bestScore = score;
          bestCrew = crew;
        }
      }

      if (bestCrew != null && bestScore > 0) {
        assignments.add(PositionAssignment(
          position: position,
          assignedCrew: bestCrew,
        ));
        assignedCrewIds.add(bestCrew.id);
      } else {
        // とりあえず未配置としてマーク
        assignments.add(PositionAssignment(position: position));
      }
    }

    // フェーズ2: 未配置クルーと未配置ポジションを柔軟にマッチング
    final unassignedCrews = availableCrews
        .where((crew) => !assignedCrewIds.contains(crew.id))
        .toList();

    for (var i = 0; i < assignments.length && unassignedCrews.isNotEmpty; i++) {
      if (!assignments[i].isAssigned) {
        // 柔軟な基準で最適なクルーを探す
        Crew? bestCrew;
        int bestScore = 0;

        for (final crew in unassignedCrews) {
          final score = assignments[i].position.getMatchScore(
            crew.counterSkill,
            crew.kitchenSkill,
            crew.hasLicense,
            crew.potatoOk,
            forceAssign: true, // 柔軟基準
          );

          if (score > bestScore) {
            bestScore = score;
            bestCrew = crew;
          }
        }

        if (bestCrew != null) {
          assignments[i] = PositionAssignment(
            position: assignments[i].position,
            assignedCrew: bestCrew,
          );
          assignedCrewIds.add(bestCrew.id);
          unassignedCrews.remove(bestCrew);
        }
      }
    }

    // それでも未配置のクルーがいる場合（ポジション数11より多い人数の場合）
    final remainingUnassigned = availableCrews
        .where((crew) => !assignedCrewIds.contains(crew.id))
        .toList();

    return AllocationResult(
      assignments: assignments,
      unassigned: remainingUnassigned,
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
