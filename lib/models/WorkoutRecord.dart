import 'package:hive/hive.dart';

part 'WorkoutRecord.g.dart'; // Hive generator를 위한 부분

@HiveType(typeId: 0)
class WorkoutRecord extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String date;

  @HiveField(2)
  Map<String, Map<String, Map<String, List<int>>>> workoutTypes;

  WorkoutRecord({
    required this.id,
    required this.date,
    required this.workoutTypes,
  });
}
