/// ポジション定義
class Position {
  final String id;
  final String name;
  final int priority; // 重要度 (1-10、高いほど重要)
  final String requiredSkillType; // 'kitchen', 'counter', 'both'
  final int minSkillLevel; // 最低スキルレベル (0-100)
  final bool requiresLicense; // 免許が必要か
  final bool requiresPotatoSkill; // ポテトスキルが必要か

  const Position({
    required this.id,
    required this.name,
    required this.priority,
    required this.requiredSkillType,
    required this.minSkillLevel,
    this.requiresLicense = false,
    this.requiresPotatoSkill = false,
  });

  /// 11の標準ポジション定義
  static const List<Position> standardPositions = [
    // 1) side1 イニシ/アッセン/スルーOT — 10
    Position(
      id: 'side1',
      name: 'side1 イニシ/アッセン/スルーOT',
      priority: 10,
      requiredSkillType: 'kitchen',
      minSkillLevel: 80,
    ),
    
    // 2) キオスクヒーロー — 9
    Position(
      id: 'kiosk_hero',
      name: 'キオスクヒーロー',
      priority: 9,
      requiredSkillType: 'counter',
      minSkillLevel: 70,
    ),
    
    // 3) カウンターOT — 8
    Position(
      id: 'counter_ot',
      name: 'カウンターOT',
      priority: 8,
      requiredSkillType: 'counter',
      minSkillLevel: 70,
    ),
    
    // 4) ドリンカー — 8
    Position(
      id: 'drinker',
      name: 'ドリンカー',
      priority: 8,
      requiredSkillType: 'kitchen',
      minSkillLevel: 60,
    ),
    
    // 5) グリル — 8
    Position(
      id: 'grill',
      name: 'グリル',
      priority: 8,
      requiredSkillType: 'kitchen',
      minSkillLevel: 70,
    ),
    
    // 6) フライ — 8
    Position(
      id: 'fry',
      name: 'フライ',
      priority: 8,
      requiredSkillType: 'kitchen',
      minSkillLevel: 60,
      requiresPotatoSkill: true,
    ),
    
    // 7) プレゼンター — 7
    Position(
      id: 'presenter',
      name: 'プレゼンター',
      priority: 7,
      requiredSkillType: 'kitchen',
      minSkillLevel: 50,
    ),
    
    // 8) side2 イニシ/アッセン/カウンターランナー2 — 6
    Position(
      id: 'side2',
      name: 'side2 イニシ/アッセン/カウンターランナー2',
      priority: 6,
      requiredSkillType: 'both',
      minSkillLevel: 50,
    ),
    
    // 9) side3 イニシ/アッセン/ライダー — 5
    Position(
      id: 'side3',
      name: 'side3 イニシ/アッセン/ライダー',
      priority: 5,
      requiredSkillType: 'both',
      minSkillLevel: 40,
      requiresLicense: true,
    ),
    
    // 10) side4 イニシ/アッセン — 4
    Position(
      id: 'side4',
      name: 'side4 イニシ/アッセン',
      priority: 4,
      requiredSkillType: 'both',
      minSkillLevel: 30,
    ),
    
    // 11) セットアッパー — 3
    Position(
      id: 'set_upper',
      name: 'セットアッパー',
      priority: 3,
      requiredSkillType: 'both',
      minSkillLevel: 20,
    ),
  ];

  /// ポジションIDから該当するPositionを取得
  static Position? getById(String id) {
    try {
      return standardPositions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 重要度順にソートされたポジションリストを取得
  static List<Position> getSortedByPriority() {
    return List.from(standardPositions)
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// クルーがこのポジションに適しているかをスコア化 (0-100)
  /// forceAssign=trueの場合、最低スキルレベル要件を無視（全員配置優先）
  int getMatchScore(
    int counterSkill,
    int kitchenSkill,
    bool hasLicense,
    bool potatoOk, {
    bool forceAssign = false,
  }) {
    // 必須条件チェック（免許とポテトは必須）
    if (requiresLicense && !hasLicense) return 0;
    if (requiresPotatoSkill && !potatoOk) return 0;

    // スキルマッチング
    int skillScore = 0;
    switch (requiredSkillType) {
      case 'kitchen':
        skillScore = kitchenSkill;
        break;
      case 'counter':
        skillScore = counterSkill;
        break;
      case 'both':
        skillScore = ((counterSkill + kitchenSkill) / 2).round();
        break;
    }

    // 全員配置モード: 最低スキルレベル要件を緩和
    if (!forceAssign && skillScore < minSkillLevel) {
      return 0; // 通常モードでは要件未満は0点
    }

    // スキルスコアに重要度を加味
    // 最低1点は保証（スキル0でも配置可能にする）
    final score = (skillScore * (priority / 10)).round();
    return score > 0 ? score : 1;
  }

  @override
  String toString() => '$name (重要度: $priority)';
}
