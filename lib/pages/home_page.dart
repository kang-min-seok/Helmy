import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: loadWorkoutData(1), // 운동 데이터 ID 1 불러오기
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다.'));
          }
          var workoutData = snapshot.data!;
          return ListView(
            children: [
              ListTile(
                title: Text('날짜: ${workoutData['date']}'),
                subtitle: Text('운동부위: ${workoutData['workout_part']}'),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var workoutData = {
            "id": 1,
            "date": '2024-03-26',
            "workout_part": '가슴',
            "rest_time": '2분',
            "workoutType": {
              "레그익스텐션": {
                "40kg": [20, 20, 20],
                "50kg": [15, 15, 15]
              },
              "스쿼트": {
                "40kg": [20, 20, 20],
                "60kg": [15, 15, 15]
              },
            }
          };
          // 데이터 저장
          await saveWorkoutData(workoutData);

        },
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
