import 'crew.dart';
import 'position.dart';

/// ポジション配置情報
class PositionAssignment {
  final Position position;
  final Crew? assignedCrew; // nullの場合は未配置

  const PositionAssignment({
    required this.position,
    this.assignedCrew,
  });

  bool get isAssigned => assignedCrew != null;

  PositionAssignment copyWith({
    Position? position,
    Crew? assignedCrew,
  }) {
    return PositionAssignment(
      position: position ?? this.position,
      assignedCrew: assignedCrew ?? this.assignedCrew,
    );
  }
}

/// 配置結果を管理するモデル (11ポジション対応)
class AllocationResult {
  final List<PositionAssignment> assignments; // 11ポジション配置
  final List<Crew> unassigned; // 未配置クルー

  AllocationResult({
    required this.assignments,
    required this.unassigned,
  });

  /// 配置済みクルー総数
  int get totalAssigned =>
      assignments.where((a) => a.isAssigned).length;

  /// 配置済みクルーのリスト
  List<Crew> get assignedCrews =>
      assignments
          .where((a) => a.isAssigned)
          .map((a) => a.assignedCrew!)
          .toList();

  /// 特定ポジションの配置を取得
  PositionAssignment? getAssignment(String positionId) {
    try {
      return assignments.firstWhere((a) => a.position.id == positionId);
    } catch (e) {
      return null;
    }
  }

  /// 重要度順にソートされた配置リスト
  List<PositionAssignment> getSortedByPriority() {
    return List.from(assignments)
      ..sort((a, b) => b.position.priority.compareTo(a.position.priority));
  }

  /// 空の配置結果を作成
  factory AllocationResult.empty() {
    return AllocationResult(
      assignments: Position.standardPositions
          .map((p) => PositionAssignment(position: p))
          .toList(),
      unassigned: [],
    );
  }

  /// 配置をコピーして更新
  AllocationResult copyWith({
    List<PositionAssignment>? assignments,
    List<Crew>? unassigned,
  }) {
    return AllocationResult(
      assignments: assignments ?? this.assignments,
      unassigned: unassigned ?? this.unassigned,
    );
  }
}
