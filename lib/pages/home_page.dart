import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/WorkoutRecord.dart';
import './widgets/workout_record_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WorkoutRecord> workoutRecords = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var recordsBox = Hive.box<WorkoutRecord>('workoutRecords');
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');


    print(recordsBox.values);
    print(typesBox.values);
    print(exercisesBox.values);
    print(setsBox.values);

    setState(() {
      workoutRecords = recordsBox.values.toList();
    });
  }

  Future<void> _addNewData() async {
    var recordsBox = Hive.box<WorkoutRecord>('workoutRecords');
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    final newId = recordsBox.values.isNotEmpty ? recordsBox.values.last.id + 1 : 1;
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 새로운 WorkoutType, Exercise, Set 생성
    final newWorkoutTypeId = typesBox.values.isNotEmpty ? typesBox.values.last.id + 1 : 0;
    final newExerciseId = exercisesBox.values.isNotEmpty ? exercisesBox.values.last.id + 1 : 0;
    final newSetId = setsBox.values.isNotEmpty ? setsBox.values.last.id + 1 : 0;

    final newSet = Set(id: newSetId, weight: '', reps: ['','','','','']);
    final newExercise = Exercise(id: newExerciseId, name: '', setIds: [newSetId]);
    final newWorkoutType = WorkoutType(id: newWorkoutTypeId, name: '', exerciseIds: [newExerciseId]);

    // 각 객체를 Hive에 저장
    await setsBox.put(newSetId, newSet);
    await exercisesBox.put(newExerciseId, newExercise);
    await typesBox.put(newWorkoutTypeId, newWorkoutType);

    // WorkoutRecord 생성 및 저장
    final newRecord = WorkoutRecord(
      id: newId,
      date: todayDate,
      workoutTypeIds: [newWorkoutTypeId],
      isEdit: true,
    );
    await recordsBox.add(newRecord);

    _loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: workoutRecords.length,
        itemBuilder: (context, index) {
          final record = workoutRecords[index];
          return WorkoutRecordWidget(record: record);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewData,
        backgroundColor: const Color(0xff0a46ff),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
