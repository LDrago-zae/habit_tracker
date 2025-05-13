import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/components/drawer.dart';
import 'package:habit_tracker/components/heat_map.dart';
import 'package:habit_tracker/components/rounded_list_tile.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).loadData();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Habit Tracker')),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final rawHabits = await Provider.of<HabitProvider>(context, listen: false).debugGetHabitsRaw();
              print('Raw habits: $rawHabits');
            },
            child: const Icon(Icons.bug_report),
            heroTag: 'debug',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              createNewHabit(context);
            },
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            child: const Icon(Icons.add, color: Colors.black),
            heroTag: 'add',
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Provider.of<HabitProvider>(context, listen: false).loadData();
            },
            child: const Text('Refresh'),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildHeatMap(),
                const SizedBox(height: 16),
                _buildHabitList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatMap() {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final Map<DateTime, int> datasets = {};
        for (var habit in provider.habits) {
          for (var date in habit.dates) {
            final normalizedDate = DateTime(date.year, date.month, date.day);
            datasets[normalizedDate] = (datasets[normalizedDate] ?? 0) + 1;
          }
        }
        print('Heatmap datasets: $datasets');
        return MyHeatMap(
          startDate: DateTime.now(), // Ignored by MyHeatMap, kept for compatibility
          datasets: datasets,
        );
      },
    );
  }

  Widget _buildHabitList() {
    return Consumer<HabitProvider>(
      key: UniqueKey(),
      builder: (context, provider, child) {
        print('Building habit list with ${provider.habits.length} habits');
        final List<Habit> currentHabits = provider.habits;
        if (currentHabits.isEmpty) {
          return const Center(child: Text('No habits added yet'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          itemCount: currentHabits.length,
          itemBuilder: (context, index) {
            final habit = currentHabits[index];
            final today = DateTime.now();
            final isCheckedToday = habit.dates.any(
                  (date) =>
              date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day,
            );

            return RoundedListTile(
              habit: habit,
              isCheckedToday: isCheckedToday,
              today: today,
            );
          },
        );
      },
    );
  }

  void createNewHabit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final TextEditingController textEditingController = TextEditingController();

            return AlertDialog(
              title: const Text('Create New Habit'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(labelText: 'Habit Name'),
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
                    final habitName = textEditingController.text.trim();
                    if (habitName.isNotEmpty) {
                      Provider.of<HabitProvider>(context, listen: false).saveHabit(
                        Habit(name: habitName, dates: []),
                      );
                      print('Created habit: $habitName');
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      print('Dialog closed');
    });
  }
}