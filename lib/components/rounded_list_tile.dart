import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';

class RoundedListTile extends StatelessWidget {
  final Habit habit;
  final bool isCheckedToday;
  final DateTime today;

  const RoundedListTile({
    super.key,
    required this.habit,
    required this.isCheckedToday,
    required this.today,
  });

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final TextEditingController textEditingController = TextEditingController(text: habit.name);

            return AlertDialog(
              title: const Text('Rename Habit'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(labelText: 'New Habit Name'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newName = textEditingController.text.trim();
                    if (newName.isNotEmpty && newName != habit.name) {
                      Provider.of<HabitProvider>(context, listen: false)
                          .updateHabitName(habit.id!, newName);
                      print('Renamed habit: ${habit.name} to $newName');
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      print('Rename dialog closed');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(habit.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id!);
              print('Deleted habit: ${habit.name}');
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            flex: 1,
          ),
          const SizedBox(width: 5.0),
          SlidableAction(
            onPressed: (context) {
              _showRenameDialog(context);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Rename',
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            flex: 1,
          ),
        ],
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.1,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          title: Text(habit.name),
          subtitle: Text(
            'Dates: ${habit.dates.isEmpty ? 'None' : habit.dates.map((d) => d.toIso8601String().split('T')[0]).join(", ")}',
          ),
          trailing: Checkbox(
            activeColor: Colors.teal,
            value: isCheckedToday,
            onChanged: (value) {
              if (value != null) {
                Provider.of<HabitProvider>(context, listen: false)
                    .checkHabitDate(habit.id!, today, value);
                print('Checked habit: ${habit.name}, date: $today, isChecked: $value');
              }
            },
          ),
        ),
      ),
    );
  }
}