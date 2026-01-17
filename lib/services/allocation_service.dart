import '../models/crew.dart';
import '../models/position.dart';
import '../models/allocation_result.dart';
import 'rating_service.dart';

/// 配置計算サービス (11ポジション対応 - 重要度優先 + 学習機能)
class AllocationService {
  /// 最適配置を計算（重要度優先 + 学習データ活用）
  static Future<AllocationResult> calculateOptimalAllocation(
    List<Crew> crews,
    int totalStaff,
    int targetSales,
  ) async {
    // 学習データを取得
    final learningDataList = await RatingService.getAllLearningData();
    final learningMap = <String, double>{};
    
    for (final data in learningDataList) {
      learningMap['${data.crewName}_${data.positionId}'] = data.totalScore;
    }
    
    // 重要度順にポジションを取得
    final positions = Position.getSortedByPriority();
    
    // 配置結果を初期化
    final assignments = <PositionAssignment>[];
    final assignedCrewIds = <int>{};
    final availableCrews = List<Crew>.from(crews);

    // フェーズ1: 重要度の高いポジションから順に最適なクルーを配置
    for (final position in positions) {
      Crew? bestCrew;
      double bestScore = 0;

      // 未配置のクルーから最適な候補を探す
      for (final crew in availableCrews) {
        if (assignedCrewIds.contains(crew.id)) continue;

        // スキルスコア
        final skillScore = position.getMatchScore(
          crew.counterSkill,
          crew.kitchenSkill,
          crew.hasLicense,
          crew.potatoOk,
          forceAssign: false,
        ).toDouble();

        // 学習スコア（過去の実績）
        final learningKey = '${crew.name}_${position.id}';
        final learningScore = learningMap[learningKey] ?? 0.0;

        // 総合スコア = スキルスコア(70%) + 学習スコア×20(30%)
        final totalScore = (skillScore * 0.7) + (learningScore * 20 * 0.3);

        if (totalScore > bestScore) {
          bestScore = totalScore;
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
        assignments.add(PositionAssignment(position: position));
      }
    }

    // フェーズ2: 未配置クルーと未配置ポジションを柔軟にマッチング
    final unassignedCrews = availableCrews
        .where((crew) => !assignedCrewIds.contains(crew.id))
        .toList();

    for (var i = 0; i < assignments.length && unassignedCrews.isNotEmpty; i++) {
      if (!assignments[i].isAssigned) {
        Crew? bestCrew;
        double bestScore = 0;

        for (final crew in unassignedCrews) {
          final skillScore = assignments[i].position.getMatchScore(
            crew.counterSkill,
            crew.kitchenSkill,
            crew.hasLicense,
            crew.potatoOk,
            forceAssign: true,
          ).toDouble();

          final learningKey = '${crew.name}_${assignments[i].position.id}';
          final learningScore = learningMap[learningKey] ?? 0.0;

          final totalScore = (skillScore * 0.7) + (learningScore * 20 * 0.3);

          if (totalScore > bestScore) {
            bestScore = totalScore;
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
