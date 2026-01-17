import 'package:flutter/material.dart';
import '../services/allocation_service.dart';
import '../models/allocation_result.dart';
import '../models/crew.dart';

class AllocationScreen extends StatefulWidget {
  const AllocationScreen({super.key});

  @override
  State<AllocationScreen> createState() => _AllocationScreenState();
}

class _AllocationScreenState extends State<AllocationScreen> {
  // ステップ管理
  int _currentStep = 0;
  
  // ステップ1: 条件入力
  double _totalStaff = 10;
  double _targetSales = 70000;
  
  // ステップ2: クルー入力
  List<Crew> _todayCrews = [];
  
  // ステップ3: 配置結果
  AllocationResult? _result;

  void _goToStep2() {
    // ステップ1からステップ2へ: クルーデータを初期化
    final crewCount = _totalStaff.toInt();
    _todayCrews = List.generate(
      crewCount,
      (index) => Crew(
        id: index,
        name: '',
        counterSkill: 50,
        kitchenSkill: 50,
        potatoOk: false,
        hasLicense: false,
      ),
    );
    
    setState(() {
      _currentStep = 1;
    });
  }

  void _goToStep3() {
    // バリデーション: 全員の名前が入力されているか
    final hasEmptyName = _todayCrews.any((crew) => crew.name.trim().isEmpty);
    
    if (hasEmptyName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('全員の名前を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 配置計算
    final result = AllocationService.calculateOptimalAllocation(
      _todayCrews,
      _totalStaff.toInt(),
      _targetSales.toInt(),
    );

    setState(() {
      _result = result;
      _currentStep = 2;
    });
  }

  void _resetAndStartOver() {
    setState(() {
      _currentStep = 0;
      _todayCrews = [];
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getStepTitle()),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_currentStep > 0) _currentStep--;
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'ステップ1: 配置条件';
      case 1:
        return 'ステップ2: クルー入力';
      case 2:
        return 'ステップ3: 配置結果';
      default:
        return '配置計算';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1ConditionInput();
      case 1:
        return _buildStep2CrewInput();
      case 2:
        return _buildStep3AllocationResult();
      default:
        return const SizedBox();
    }
  }

  // ステップ1: 配置条件入力
  Widget _buildStep1ConditionInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 進捗インジケーター
          _buildStepIndicator(),
          const SizedBox(height: 24),
          
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        '今日の配置条件',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'in人数: ${_totalStaff.toInt()}人',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _totalStaff,
                    min: 2,
                    max: 20,
                    divisions: 18,
                    activeColor: Colors.orange,
                    label: '${_totalStaff.toInt()}人',
                    onChanged: (value) {
                      setState(() {
                        _totalStaff = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('2人', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('20人', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '目標セールス: ${_targetSales.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}円',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _targetSales,
                    min: 0,
                    max: 200000,
                    divisions: 40,
                    activeColor: Colors.orange,
                    label: '${_targetSales.toInt()}円',
                    onChanged: (value) {
                      setState(() {
                        _targetSales = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0円', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('200,000円', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '次のステップでクルー情報を入力します',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _goToStep2,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_forward),
                const SizedBox(width: 8),
                Text(
                  '次へ: ${_totalStaff.toInt()}人のクルー入力',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 進捗インジケーター
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(1, _currentStep >= 0),
        Expanded(child: _buildStepLine(_currentStep >= 1)),
        _buildStepCircle(2, _currentStep >= 1),
        Expanded(child: _buildStepLine(_currentStep >= 2)),
        _buildStepCircle(3, _currentStep >= 2),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? Colors.orange : Colors.grey.shade300,
    );
  }

  // ステップ2: クルー入力
  Widget _buildStep2CrewInput() {
    return Column(
      children: [
        // 進捗インジケーター
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildStepIndicator(),
        ),
        // クルーリスト
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _todayCrews.length,
            itemBuilder: (context, index) {
              return _buildCrewInputCard(index);
            },
          ),
        ),
        // 次へボタン
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _goToStep3,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome),
                SizedBox(width: 8),
                Text(
                  '配置を計算',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCrewInputCard(int index) {
    final crew = _todayCrews[index];
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '名前',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _todayCrews[index] = Crew(
                          id: crew.id,
                          name: value,
                          counterSkill: crew.counterSkill,
                          kitchenSkill: crew.kitchenSkill,
                          potatoOk: crew.potatoOk,
                          hasLicense: crew.hasLicense,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'カウンタースキル: ${crew.counterSkill}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: crew.counterSkill.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: Colors.blue,
              label: '${crew.counterSkill}',
              onChanged: (value) {
                setState(() {
                  _todayCrews[index] = Crew(
                    id: crew.id,
                    name: crew.name,
                    counterSkill: value.toInt(),
                    kitchenSkill: crew.kitchenSkill,
                    potatoOk: crew.potatoOk,
                    hasLicense: crew.hasLicense,
                  );
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              '厨房スキル: ${crew.kitchenSkill}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: crew.kitchenSkill.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              activeColor: Colors.red,
              label: '${crew.kitchenSkill}',
              onChanged: (value) {
                setState(() {
                  _todayCrews[index] = Crew(
                    id: crew.id,
                    name: crew.name,
                    counterSkill: crew.counterSkill,
                    kitchenSkill: value.toInt(),
                    potatoOk: crew.potatoOk,
                    hasLicense: crew.hasLicense,
                  );
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('ポテト可', style: TextStyle(fontSize: 13)),
                    value: crew.potatoOk,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _todayCrews[index] = Crew(
                          id: crew.id,
                          name: crew.name,
                          counterSkill: crew.counterSkill,
                          kitchenSkill: crew.kitchenSkill,
                          potatoOk: value ?? false,
                          hasLicense: crew.hasLicense,
                        );
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('免許有', style: TextStyle(fontSize: 13)),
                    value: crew.hasLicense,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _todayCrews[index] = Crew(
                          id: crew.id,
                          name: crew.name,
                          counterSkill: crew.counterSkill,
                          kitchenSkill: crew.kitchenSkill,
                          potatoOk: crew.potatoOk,
                          hasLicense: value ?? false,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ステップ3: 配置結果
  Widget _buildStep3AllocationResult() {
    if (_result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 進捗インジケーター
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildStepIndicator(),
        ),
        // 配置結果リスト
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildAllocationResults(_result!),
            ),
          ),
        ),
        // 最初からやり直すボタン
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _resetAndStartOver,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh),
                SizedBox(width: 8),
                Text(
                  '新しい配置を作成',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAllocationResults(AllocationResult result) {
    final widgets = <Widget>[];

    // 統計情報カード
    final stats = AllocationService.getDetailedStats(result);
    widgets.add(
      Card(
        elevation: 2,
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    '配置サマリー',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatRow('配置済み', '${stats['totalAssigned']}人'),
              _buildStatRow('未配置', '${stats['unassignedCount']}人'),
              _buildStatRow('厨房ポジション', '${stats['kitchenPositions']}'),
              _buildStatRow('カウンターポジション', '${stats['counterPositions']}'),
              _buildStatRow('両対応ポジション', '${stats['bothPositions']}'),
              _buildStatRow('平均スキル', stats['averageSkill']),
            ],
          ),
        ),
      ),
    );
    widgets.add(const SizedBox(height: 16));

    // 重要度順にポジション配置を表示
    final sortedAssignments = result.getSortedByPriority();
    
    for (final assignment in sortedAssignments) {
      widgets.add(_buildPositionCard(assignment));
    }

    // 未配置クルー
    if (result.unassigned.isNotEmpty) {
      widgets.add(
        Card(
          elevation: 2,
          color: Colors.grey.shade300,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_off, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '未配置クルー (${result.unassigned.length}人)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result.unassigned.map((c) => c.name).join(', '),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard(assignment) {
    final position = assignment.position;
    final crew = assignment.assignedCrew;
    final isAssigned = assignment.isAssigned;

    // 重要度に応じた色
    Color getColorByPriority(int priority) {
      if (priority >= 9) return Colors.red;
      if (priority >= 7) return Colors.orange;
      if (priority >= 5) return Colors.blue;
      return Colors.green;
    }

    final color = getColorByPriority(position.priority);

    return Column(
      children: [
        Card(
          elevation: 2,
          color: isAssigned ? color : Colors.grey.shade400,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        position.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '重要度: ${position.priority}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isAssigned) ...[
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        crew!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.restaurant, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '厨房: ${crew.kitchenSkill}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.storefront, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        'カウンター: ${crew.counterSkill}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Row(
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.white70),
                      SizedBox(width: 4),
                      Text(
                        '未配置',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
