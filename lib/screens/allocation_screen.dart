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

    // ライダー
    if (result.riders.isNotEmpty) {
      widgets.add(_buildResultCard(
        '🏍️ ライダー',
        result.riders,
        Colors.green,
      ));
    }

    // ポテト
    if (result.potato.isNotEmpty) {
      widgets.add(_buildResultCard(
        '🔥 ポテト担当',
        result.potato,
        Colors.orange,
      ));
    }

    // 厨房
    if (result.kitchen.isNotEmpty) {
      widgets.add(_buildResultCard(
        '🍳 厨房',
        result.kitchen,
        Colors.red,
      ));
    }

    // カウンター
    if (result.counter.isNotEmpty) {
      widgets.add(_buildResultCard(
        '💻 カウンター',
        result.counter,
        Colors.blue,
      ));
    }

    // ドライブスルー
    if (result.drive.isNotEmpty) {
      widgets.add(_buildResultCard(
        '🚗 ドライブスルー',
        result.drive,
        Colors.purple,
      ));
    }

    // その他
    final others = <String>[];
    if (result.outside.isNotEmpty) {
      others.add('外キャッシャー: ${result.outside.length}人');
    }
    if (result.hot.isNotEmpty) {
      others.add('ホット: ${result.hot.length}人');
    }

    if (others.isNotEmpty) {
      widgets.add(
        Card(
          elevation: 2,
          color: Colors.grey.shade700,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'その他',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  others.join(' / '),
                  style: const TextStyle(color: Colors.white),
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

  Widget _buildResultCard(String title, List crews, Color color) {
    return Column(
      children: [
        Card(
          elevation: 2,
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${crews.length}人',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  crews.map((c) => c.name).join(', '),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
