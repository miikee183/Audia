import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DateTime _selectedMonth;
  final Set<int> _audioDays = {1, 5, 12, 15, 20, 23, 27};

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar y nombre
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primaryColor.withAlpha(60),
                  child: const Icon(Icons.person, size: 48, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                const Text('Usuario', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('@usuario', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(count: '42', label: 'Audios'),
              _Stat(count: '128', label: 'Seguidores'),
              _Stat(count: '96', label: 'Siguiendo'),
            ],
          ),

          const SizedBox(height: 24),

          // Calendario
          Card(
            color: AppTheme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Mes y navegaciÃ³n
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white54),
                        onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
                      ),
                      Text(
                        '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white54),
                        onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // DÃ­as de la semana
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['D', 'L', 'M', 'M', 'J', 'V', 'S'].map((d) =>
                      SizedBox(
                        width: 36,
                        child: Text(d, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 8),

                  // Grid de dÃ­as
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (int i = 0; i < firstWeekday; i++)
                        const SizedBox(width: 36, height: 36),
                      for (int day = 1; day <= daysInMonth; day++)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _audioDays.contains(day)
                                ? AppTheme.primaryColor
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(
                                color: _audioDays.contains(day) ? Colors.black : Colors.white54,
                                fontSize: 13,
                                fontWeight: _audioDays.contains(day) ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Ãšltimos audios
          const Text('Ãšltimos audios', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (i) => Card(
              color: AppTheme.cardColor,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.play_arrow, color: AppTheme.primaryColor),
                ),
                title: Text('Audio ${i + 1}', style: const TextStyle(color: Colors.white)),
                subtitle: const Text('320 reproducciones', style: TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('${[24, 18, 42][i]}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return names[month - 1];
  }
}

class _Stat extends StatelessWidget {
  final String count;
  final String label;

  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }
}

