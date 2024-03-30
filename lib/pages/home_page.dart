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
    var box = Hive.box<WorkoutRecord>('workoutRecords');
    setState(() {
      workoutRecords = box.values.toList();
    });
  }

  Future<void> _addNewData() async {
    var box = Hive.box<WorkoutRecord>('workoutRecords');

    final newId = box.values.isNotEmpty ? box.values.last.id + 1 : 1;
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final newRecord = WorkoutRecord(
      id: newId,
      date: todayDate,
      workoutTypes: {
        "가슴": {
          "레그익스텐션": {"40": [20, 20, 20], "50": [15, 15, 15]},
          "스쿼트": {"40": [20, 20, 20], "60": [15, 15, 15]},
        },
        "복근": {
          "크런치": {"0": [20, 20, 20]},
        }
      },
    );

    await box.add(newRecord);
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
