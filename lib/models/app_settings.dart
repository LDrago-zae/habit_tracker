class AppSettings {
  final int? id;
  final DateTime? firstLaunchDate;

  AppSettings({this.id, this.firstLaunchDate});

  Map<String, dynamic> toMap() {
    return {'id': id, 'firstLaunchDate': firstLaunchDate?.toIso8601String()};
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as int?,
      firstLaunchDate:
          map['firstLaunchDate'] != null
              ? DateTime.parse(map['firstLaunchDate'] as String)
              : null,
    );
  }
}
