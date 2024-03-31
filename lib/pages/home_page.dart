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

    final newId = recordsBox.values.isNotEmpty ? recordsBox.values.last.id + 1 : 1;
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // WorkoutRecord만 생성하고, workoutTypeIds는 빈 배열로 초기화
    final newRecord = WorkoutRecord(
      id: newId,
      date: todayDate,
      workoutTypeIds: [],  // 빈 배열로 초기화
    );

    await recordsBox.add(newRecord);  // 새로운 WorkoutRecord 저장
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
