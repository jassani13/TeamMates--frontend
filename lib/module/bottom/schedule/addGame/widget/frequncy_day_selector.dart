import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class FrequencyDaySelector extends StatefulWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onSelectionChanged;

  const FrequencyDaySelector({
    super.key,
    required this.selectedDays,
    required this.onSelectionChanged,
  });

  @override
  State<FrequencyDaySelector> createState() => _FrequencyDaySelectorState();
}

class _FrequencyDaySelectorState extends State<FrequencyDaySelector> {
  late List<int> _selectedDays;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _selectedDays = List.from(widget.selectedDays);
  }

  void _toggleDay(int index) {
    final day = index + 1; // 1-based index
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.clear(); // Unselect if same day tapped again
      } else {
        _selectedDays = [day]; // Select new day
      }
    });
    widget.onSelectionChanged(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Frequency",
          style: TextStyle().normal16w500.textColor(
            AppColor.black12Color,
          ),
        ),
        Gap(4),
        Wrap(
          spacing: 8,
          children: List.generate(_days.length, (index) {
            final isSelected = _selectedDays.contains(index + 1);
            return ChoiceChip(
              label: Text(_days[index]),
              selected: isSelected,
              onSelected: (_) => _toggleDay(index),
              checkmarkColor: Colors.white,
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }),
        ),
      ],
    );
  }
}
