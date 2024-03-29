import 'dart:convert';

class WorkoutRecord {
  int id;
  String date;
  Map<String, Map<String, Map<String, List<int>>>> workoutTypes;

  WorkoutRecord({
    required this.id,
    required this.date,
    Map<String, Map<String, Map<String, List<int>>>>? workoutTypes,
  }) : workoutTypes = workoutTypes ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'workoutTypes': workoutTypes.map((part, exercises) =>
          MapEntry(part, exercises.map((exercise, sets) =>
              MapEntry(exercise, sets.map((weight, reps) =>
                  MapEntry(weight, reps)))))),
    };
  }

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    var workoutTypesJson = json['workoutTypes'] as Map<String, dynamic>;
    var workoutTypes = workoutTypesJson.map((part, exercisesJson) =>
        MapEntry(
            part,
            (exercisesJson as Map<String, dynamic>).map((exercise, setsJson) =>
                MapEntry(
                    exercise,
                    (setsJson as Map<String, dynamic>).map((weight, reps) =>
                        MapEntry(weight, List<int>.from(reps)))))));

    return WorkoutRecord(
      id: json['id'],
      date: json['date'],
      workoutTypes: workoutTypes,
    );
  }
}
