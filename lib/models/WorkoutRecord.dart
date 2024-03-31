import 'package:hive/hive.dart';

part 'WorkoutRecord.g.dart'; // Hive generator를 위한 부분

@HiveType(typeId: 0)
class WorkoutRecord extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String date;

  @HiveField(2)
  List<int> workoutTypeIds; // 운동 유형의 ID 목록

  WorkoutRecord({
    required this.id,
    required this.date,
    required this.workoutTypeIds,
  });
  @override
  String toString() {
    return 'WorkoutRecord(id: $id, date: $date, workoutTypeIds: $workoutTypeIds)';
  }
}

@HiveType(typeId: 1)
class WorkoutType extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<int> exerciseIds; // 운동의 ID 목록

  WorkoutType({
    required this.id,
    required this.name,
    required this.exerciseIds,
  });
  @override
  String toString() {
    return 'WorkoutType(id: $id, name: $name, exerciseIds: $exerciseIds)';
  }
}

@HiveType(typeId: 2)
class Exercise extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<int> setIds; // 세트의 ID 목록

  Exercise({
    required this.id,
    required this.name,
    required this.setIds,
  });
  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, exerciseIds: $setIds)';
  }
}

@HiveType(typeId: 3)
class Set extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String weight;

  @HiveField(2)
  List<int> reps;

  Set({
    required this.id,
    required this.weight,
    required this.reps,
  });
  @override
  String toString() {
    return 'Set(id: $id, name: $weight, exerciseIds: $reps)';
  }
}
