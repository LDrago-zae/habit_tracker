import 'dart:convert';

class Habit {
  final int? id;
  final String name;
  final List<DateTime> dates;

  Habit({this.id, required this.name, this.dates = const []});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dates': jsonEncode(dates.map((date) => date.toIso8601String()).toList()),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      dates:
          map['dates'] != null
              ? (jsonDecode(map['dates'] as String) as List<dynamic>)
                  .map((dateStr) => DateTime.parse(dateStr as String))
                  .toList()
              : [],
    );
  }
}
