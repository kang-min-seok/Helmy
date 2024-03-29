import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
    final prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('workoutRecords');
    if (storedData != null) {
      setState(() {
        List<dynamic> recordsJson = jsonDecode(storedData) as List<dynamic>;
        workoutRecords = recordsJson.map((recordJson) => WorkoutRecord.fromJson(recordJson)).toList();
      });
    }
  }

  Future<void> _addNewData() async {
    final newId = workoutRecords.isNotEmpty ? workoutRecords.last.id + 1 : 1;
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Create a new workout record with empty workout part and types
    final newRecord = WorkoutRecord(
      id: newId,
      date: todayDate,
      workoutTypes: {
        "가슴": {
          "레그익스텐션": {"40": [20, 20, 20], "50": [15, 15, 15]},
          "스쿼트": {"40": [20, 20, 20], "60": [15, 15, 15]},
        },
        "복근": {
          "크런치": {"0": [20, 20, 20], },
        }

      }, // Initialize with an empty map
    );

    setState(() {
      workoutRecords.add(newRecord);
    });

    // Save the updated workout records list to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String encodedData = jsonEncode(workoutRecords.map((record) => record.toJson()).toList());
    await prefs.setString('workoutRecords', encodedData);
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