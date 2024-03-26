import 'dart:convert';

class WorkoutRecord {
  final int id;
  final String date;
  final String bodyPart;
  final String restTime;
  final Map<String, dynamic> exerciseDetails;

  WorkoutRecord({
    required this.id,
    required this.date,
    required this.bodyPart,
    required this.restTime,
    required this.exerciseDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '날짜': date,
      '운동부위': bodyPart,
      '휴식시간': restTime,
      '운동종류': exerciseDetails,
    };
  }

  static WorkoutRecord fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      id: json['id'],
      date: json['날짜'],
      bodyPart: json['운동부위'],
      restTime: json['휴식시간'],
      exerciseDetails: json['운동종류'],
    );
  }
}
