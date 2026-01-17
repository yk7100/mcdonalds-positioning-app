/// クルー情報を管理するモデル
class Crew {
  final int id;
  final String name;
  final int counterSkill; // カウンタースキル (0-100)
  final int kitchenSkill; // 厨房スキル (0-100)
  final bool potatoOk; // ポテト対応可能か
  final bool hasLicense; // 免許保有

  Crew({
    required this.id,
    required this.name,
    required this.counterSkill,
    required this.kitchenSkill,
    required this.potatoOk,
    required this.hasLicense,
  });

  /// JSONからCrewオブジェクトを作成
  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'] as int,
      name: json['name'] as String,
      counterSkill: json['counterSkill'] as int,
      kitchenSkill: json['kitchenSkill'] as int,
      potatoOk: json['potatoOk'] as bool,
      hasLicense: json['hasLicense'] as bool,
    );
  }

  /// CrewオブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'counterSkill': counterSkill,
      'kitchenSkill': kitchenSkill,
      'potatoOk': potatoOk,
      'hasLicense': hasLicense,
    };
  }

  /// 総合スキル値
  int get totalSkill => counterSkill + kitchenSkill;

  /// 得意分野
  String get skillType {
    if (counterSkill == 0 && kitchenSkill == 0) return '新人';
    return counterSkill > kitchenSkill ? 'カウンター' : '厨房';
  }

  /// 新人判定
  bool get isNew => counterSkill == 0 && kitchenSkill == 0;
}
