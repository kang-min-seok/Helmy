import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// LocalStorage 인스턴스 생성
final LocalStorage storage = LocalStorage('workout_data.json');

Future<void> saveWorkoutData(Map<String, dynamic> workoutData) async {
  await storage.ready;
  await storage.setItem('workout_${workoutData['id']}', json.encode(workoutData));
}

Future<Map<String, dynamic>?> loadWorkoutData(int id) async {
  await storage.ready;
  var data = storage.getItem('workout_$id');
  if (data != null) {
    return json.decode(data);
  }
  return null;
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> workoutList = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await storage.ready;
    // LocalStorage에서 모든 데이터를 불러옵니다.
    final allData = storage.getItem('workoutData') ?? [];
    setState(() {
      workoutList = List<Map<String, dynamic>>.from(allData);
    });
  }

  Future<void> _addNewData() async {
    final newId = workoutList.length + 1; // 새로운 ID를 생성합니다.
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 오늘 날짜를 가져옵니다.
    final newWorkoutData = {
      "id": newId,
      "date": todayDate,
      "workout_part": '',
      "rest_time": '',
      "workoutType": {}
    };

    // 새로운 데이터를 리스트에 추가하고 저장합니다.
    workoutList.add(newWorkoutData);
    await storage.setItem('workoutData', json.encode(workoutList));
    _loadAllData(); // 화면을 업데이트하기 위해 데이터를 다시 불러옵니다.
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: workoutList.length,
        itemBuilder: (context, index) {
          final workoutData = workoutList[index];
          return ListTile(
            title: Text('날짜: ${workoutData['date']}'),
            subtitle: Text('운동부위: ${workoutData['workout_part']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewData, // 버튼을 누를 때 _saveData를 호출합니다.
        backgroundColor: const Color(0xff0a46ff),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 버튼 위치
    );
  }
}
