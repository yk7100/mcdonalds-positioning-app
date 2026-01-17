import 'allocation_result.dart';

/// 配置評価データ
class AllocationRating {
  final String id; // ユニークID
  final DateTime date; // 評価日時
  final int staffCount; // 人数
  final int targetSales; // 目標セールス
  final List<CrewAssignment> assignments; // 配置内容
  final int rating; // 評価 (1-5)
  final String comment; // コメント

  AllocationRating({
    required this.id,
    required this.date,
    required this.staffCount,
    required this.targetSales,
    required this.assignments,
    required this.rating,
    required this.comment,
  });

  /// JSONからAllocationRatingオブジェクトを作成
  factory AllocationRating.fromJson(Map<String, dynamic> json) {
    return AllocationRating(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      staffCount: json['staffCount'] as int,
      targetSales: json['targetSales'] as int,
      assignments: (json['assignments'] as List)
          .map((a) => CrewAssignment.fromJson(a as Map<String, dynamic>))
          .toList(),
      rating: json['rating'] as int,
      comment: json['comment'] as String,
    );
  }

  /// AllocationRatingオブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'staffCount': staffCount,
      'targetSales': targetSales,
      'assignments': assignments.map((a) => a.toJson()).toList(),
      'rating': rating,
      'comment': comment,
    };
  }

  /// AllocationResultから評価データを作成
  static AllocationRating fromAllocationResult(
    AllocationResult result,
    int staffCount,
    int targetSales,
    int rating,
    String comment,
  ) {
    final assignments = result.assignments
        .where((a) => a.isAssigned)
        .map((a) => CrewAssignment(
              crewId: a.assignedCrew!.id,
              crewName: a.assignedCrew!.name,
              positionId: a.position.id,
              positionName: a.position.name,
            ))
        .toList();

    return AllocationRating(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      staffCount: staffCount,
      targetSales: targetSales,
      assignments: assignments,
      rating: rating,
      comment: comment,
    );
  }
}

/// クルー配置情報（評価用）
class CrewAssignment {
  final int crewId;
  final String crewName;
  final String positionId;
  final String positionName;

  CrewAssignment({
    required this.crewId,
    required this.crewName,
    required this.positionId,
    required this.positionName,
  });

  factory CrewAssignment.fromJson(Map<String, dynamic> json) {
    return CrewAssignment(
      crewId: json['crewId'] as int,
      crewName: json['crewName'] as String,
      positionId: json['positionId'] as String,
      positionName: json['positionName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crewId': crewId,
      'crewName': crewName,
      'positionId': positionId,
      'positionName': positionName,
    };
  }

  /// クルー×ポジションのキー
  String get key => '${crewName}_$positionId';
}

/// 学習データ（クルー×ポジションの相性）
class LearningData {
  final String crewName; // クルー名
  final String positionId; // ポジションID
  final int totalRatings; // 評価回数
  final double averageRating; // 平均評価
  final int successCount; // 高評価(4-5)の回数

  LearningData({
    required this.crewName,
    required this.positionId,
    required this.totalRatings,
    required this.averageRating,
    required this.successCount,
  });

  /// 成功率 (0.0 - 1.0)
  double get successRate => totalRatings > 0 ? successCount / totalRatings : 0.0;

  /// 信頼度スコア（データ量に応じた重み）
  double get confidenceScore {
    // データが少ないうちは信頼度が低い
    if (totalRatings == 0) return 0.0;
    if (totalRatings < 3) return 0.3;
    if (totalRatings < 5) return 0.6;
    return 1.0;
  }

  /// 総合スコア（平均評価 × 信頼度）
  double get totalScore => averageRating * confidenceScore;

  factory LearningData.fromJson(Map<String, dynamic> json) {
    return LearningData(
      crewName: json['crewName'] as String,
      positionId: json['positionId'] as String,
      totalRatings: json['totalRatings'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      successCount: json['successCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crewName': crewName,
      'positionId': positionId,
      'totalRatings': totalRatings,
      'averageRating': averageRating,
      'successCount': successCount,
    };
  }

  /// 初期データ
  static LearningData initial(String crewName, String positionId) {
    return LearningData(
      crewName: crewName,
      positionId: positionId,
      totalRatings: 0,
      averageRating: 0.0,
      successCount: 0,
    );
  }

  /// 評価を追加して更新
  LearningData addRating(int rating) {
    final newTotal = totalRatings + 1;
    final newAverage = (averageRating * totalRatings + rating) / newTotal;
    final newSuccess = rating >= 4 ? successCount + 1 : successCount;

    return LearningData(
      crewName: crewName,
      positionId: positionId,
      totalRatings: newTotal,
      averageRating: newAverage,
      successCount: newSuccess,
    );
  }
}
