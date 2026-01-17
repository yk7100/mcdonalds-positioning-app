import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crew.dart';
import '../providers/crew_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  double _counterSkill = 0;
  double _kitchenSkill = 0;
  bool _potatoOk = false;
  bool _hasLicense = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    setState(() {
      _counterSkill = 0;
      _kitchenSkill = 0;
      _potatoOk = false;
      _hasLicense = false;
    });
  }

  Future<void> _addCrew() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('氏名を入力してください')),
      );
      return;
    }

    final crew = Crew(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      counterSkill: _counterSkill.toInt(),
      kitchenSkill: _kitchenSkill.toInt(),
      potatoOk: _potatoOk,
      hasLicense: _hasLicense,
    );

    await context.read<CrewProvider>().addCrew(crew);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('クルーを登録しました!'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final crewProvider = context.watch<CrewProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('マクドナルド配置アプリ'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // クルー登録カード
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_add, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'クルー登録',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '氏名',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('カウンター評価: ${_counterSkill.toInt()}/100'),
                    Slider(
                      value: _counterSkill,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          _counterSkill = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('厨房評価: ${_kitchenSkill.toInt()}/100'),
                    Slider(
                      value: _kitchenSkill,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          _kitchenSkill = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _potatoOk,
                      onChanged: (value) {
                        setState(() {
                          _potatoOk = value ?? false;
                        });
                      },
                      title: const Text('ポテトができる'),
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _hasLicense,
                      onChanged: (value) {
                        setState(() {
                          _hasLicense = value ?? false;
                        });
                      },
                      title: const Text('免許を持っている'),
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '18歳未満の方は、免許を持っていてもチェックを入れないでください',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addCrew,
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
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text(
                            'クルーを登録',
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

            // 登録済みクルー一覧
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          '登録済みクルー',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (crewProvider.crews.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'クルーが登録されていません',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: crewProvider.crews.length,
                        itemBuilder: (context, index) {
                          final crew = crewProvider.crews[index];
                          return _buildCrewItem(context, crew);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrewItem(BuildContext context, Crew crew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: Colors.orange, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      crew.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (crew.isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '新🌱',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  onPressed: () => _deleteCrew(context, crew),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSkillBar(
                    'カウンター',
                    crew.counterSkill,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSkillBar(
                    '厨房',
                    crew.kitchenSkill,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'カウンター: ${crew.counterSkill}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Text(
                  '厨房: ${crew.kitchenSkill}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Text(
                  crew.skillType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: crew.potatoOk ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'ポテト: ${crew.potatoOk ? '可' : '不可'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: crew.potatoOk ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.motorcycle,
                  size: 16,
                  color: crew.hasLicense ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '免許: ${crew.hasLicense ? '有' : '無'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: crew.hasLicense ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteCrew(BuildContext context, Crew crew) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: Text('${crew.name}を削除しますか?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<CrewProvider>().deleteCrew(crew.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('クルーを削除しました'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
