class WorkoutRecord {
  final String date;
  final String workoutPart;
  final Map<String, dynamic> workoutTypes;

  WorkoutRecord({
    required this.date,
    required this.workoutPart,
    required this.workoutTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'workoutPart': workoutPart,
      'workoutTypes': workoutTypes,
    };
  }

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      date: json['date'] as String,
      workoutPart: json['workoutPart'] as String,
      workoutTypes: json['workoutTypes'] as Map<String, dynamic>,
    );
  }
}