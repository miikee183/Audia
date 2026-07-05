import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';

class DateOfBirthPicker extends StatefulWidget {
  final ValueChanged<DateTime>? onChanged;

  const DateOfBirthPicker({super.key, this.onChanged});

  @override
  State<DateOfBirthPicker> createState() => _DateOfBirthPickerState();
}

class _DateOfBirthPickerState extends State<DateOfBirthPicker> {
  late int _day;
  late int _month;
  late int _year;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  static List<String> _monthNames(String locale) {
    final months = [
      AppStrings.month1, AppStrings.month2, AppStrings.month3,
      AppStrings.month4, AppStrings.month5, AppStrings.month6,
      AppStrings.month7, AppStrings.month8, AppStrings.month9,
      AppStrings.month10, AppStrings.month11, AppStrings.month12,
    ];
    return months;
  }

  @override
  void initState() {
    super.initState();
    _day = 1;
    _month = 1;
    _year = 2000;
    _dayController = FixedExtentScrollController(initialItem: 0);
    _monthController = FixedExtentScrollController(initialItem: 0);
    _yearController = FixedExtentScrollController(initialItem: _year - 1920);
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  bool _isLeapYear(int y) => (y % 400 == 0) || (y % 4 == 0 && y % 100 != 0);

  int _daysInMonth(int m, int y) {
    if (m == 2) return _isLeapYear(y) ? 29 : 28;
    return [4, 6, 9, 11].contains(m) ? 30 : 31;
  }

  int get _maxDays => _daysInMonth(_month, _year);
  int get _currentYear => DateTime.now().year;

  void _onMonthChanged(int index) {
    setState(() {
      _month = index + 1;
      if (_day > _maxDays) {
        _day = _maxDays;
        _dayController.jumpToItem(_day - 1);
      }
    });
    widget.onChanged?.call(DateTime(_year, _month, _day));
  }

  void _onYearChanged(int index) {
    setState(() {
      _year = 1920 + index;
      if (_day > _maxDays) {
        _day = _maxDays;
        _dayController.jumpToItem(_day - 1);
      }
    });
    widget.onChanged?.call(DateTime(_year, _month, _day));
  }

  void _onDayChanged(int index) {
    setState(() => _day = index + 1);
    widget.onChanged?.call(DateTime(_year, _month, _day));
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(_maxDays, (i) => (i + 1).toString().padLeft(2, '0'));
    final years = List.generate(_currentYear - 1920 + 1, (i) => (1920 + i).toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.birthDate,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(200),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: _buildWheel(label: AppStrings.dayLabel, items: days, controller: _dayController, onChanged: _onDayChanged)),
              Expanded(child: _buildWheel(label: AppStrings.monthLabel, items: _monthNames(AppStrings.locale), controller: _monthController, onChanged: _onMonthChanged)),
              Expanded(flex: 2, child: _buildWheel(label: AppStrings.yearLabel, items: years, controller: _yearController, onChanged: _onYearChanged)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWheel({
    required String label,
    required List<String> items,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(150))),
        SizedBox(
          height: 150,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: 36,
            selectionOverlay: null,
            backgroundColor: Colors.transparent,
            onSelectedItemChanged: onChanged,
            children: items.map((item) {
              return Center(child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 16)));
            }).toList(),
          ),
        ),
      ],
    );
  }
}

