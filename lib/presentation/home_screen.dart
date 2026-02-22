import 'package:flutter/material.dart';

import 'package:habitat_tracker/models/habit_model.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _myBox = Hive.box<Habit>('habits_box');
  @override
  void initState() {
    if (_myBox.isNotEmpty) {
      habits = _myBox.values.toList();
    }
    super.initState();
  }

  final _controller = TextEditingController();
  List<Habit> habits = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Habit Tracker')),
      body: ListView.separated(
        itemCount: habits.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Dismissible(
              direction: DismissDirection.endToStart,
              key: ValueKey(habits[index].title),
              onDismissed: (i) {
                setState(() {
                  habits.removeAt(index);
                });
                updateDatabase();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Привычка удалена')));
              },
              background: Container(color: Colors.transparent),
              secondaryBackground: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
            
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.red,
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20),
                  child: Center(child: Icon(Icons.delete, color: Colors.white)),
                ),
              ),
              child: HabitTile(
                title: habits[index].title,
                isCompleted: habits[index].isCompleted,
                onChanged: (bool? newValue) {
                  setState(() {
                    habits[index].isCompleted = newValue ?? false;
                  });
                  updateDatabase();
                },
              ),
            ),
          ),
        ),
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: 10),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createNewHabit(_controller),
        child: Icon(Icons.add),
      ),
    );
  }

  void updateDatabase() {
    _myBox.clear();
    _myBox.addAll(habits);
  }

  void createNewHabit(TextEditingController? controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Добавить привычку'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Название...'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                habits.add(Habit(title: _controller.text, isCompleted: false));
              });
              updateDatabase();
              _controller.clear();
              Navigator.of(context).pop();
            },
            child: Text('Добавить'),
          ),
        ],
      ),
    );
  }
}

class HabitTile extends StatelessWidget {
  final String? title;
  final bool? isCompleted;
  final Function(bool?)? onChanged;
  const HabitTile({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return AnimatedContainer(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isCompleted == false ? Color(0xFFFFFFFF) : Color(0xFF4ADE80),
        border: Border.all(
          color: isCompleted == true
              ? Color(0xFF4ADE80)
              : Colors.grey.shade200,
          width: 2,
        ),
      ),
    
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title ?? 'Имя не передано',
            style: theme.bodyLarge?.copyWith(
              decoration: isCompleted == false
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
              fontWeight: FontWeight.w600,
            ),
          ),
          Checkbox(value: isCompleted, onChanged: onChanged),
        ],
      ),
    );
  }
}
