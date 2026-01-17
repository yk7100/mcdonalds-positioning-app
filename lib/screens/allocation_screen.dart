import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crew_provider.dart';
import '../services/allocation_service.dart';
import '../models/allocation_result.dart';

class AllocationScreen extends StatefulWidget {
  const AllocationScreen({super.key});

  @override
  State<AllocationScreen> createState() => _AllocationScreenState();
}

class _AllocationScreenState extends State<AllocationScreen> {
  double _totalStaff = 10;
  double _targetSales = 70000;
  AllocationResult? _result;

  void _calculateAllocation() {
    final crews = context.read<CrewProvider>().crews;

    if (crews.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('クルーを登録してください')),
      );
      return;
    }

    final result = AllocationService.calculateOptimalAllocation(
      crews,
      _totalStaff.toInt(),
      _targetSales.toInt(),
    );

    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置計算'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 配置条件カード
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          '配置条件',
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
                      style: const TextStyle(fontSize: 14),
                    ),
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
                      style: const TextStyle(fontSize: 14),
                    ),
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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '70,000円以上でポテト独立',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _calculateAllocation,
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
                            '最適配置を計算',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 配置結果
            if (_result != null) ..._buildAllocationResults(_result!),
          ],
        ),
      ),
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
