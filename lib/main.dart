import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './pages/home_page.dart';
import './pages/calendar_page.dart';
import './pages/timer_page.dart';
import './pages/setting_page.dart';
import './models/WorkoutRecord.dart'; // WorkoutRecord 모델 import
import 'notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진과 위젯 바인딩을 초기화
  await Hive.initFlutter(); // Hive를 초기화
  Hive.registerAdapter(WorkoutRecordAdapter()); // WorkoutRecord 어댑터 등록
  Hive.registerAdapter(WorkoutTypeAdapter()); // WorkoutType 어댑터 등록
  Hive.registerAdapter(ExerciseAdapter()); // Exercise 어댑터 등록
  Hive.registerAdapter(SetAdapter());
  // Set 어댑터 등록
  await Hive.openBox<WorkoutRecord>('workoutRecords'); // workoutRecords 박스 열기
  await Hive.openBox<WorkoutType>('workoutTypes'); // workoutTypes 박스 열기
  await Hive.openBox<Exercise>('exercises'); // exercises 박스 열기
  await Hive.openBox<Set>('sets'); // sets 박스 열기
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '헬미',
      theme: ThemeData(
        fontFamily: "Dohyeon",
        useMaterial3: true,
        dividerColor: Colors.transparent,
      ),
      debugShowCheckedModeBanner: false,
      home: const BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  final BottomNavigationBarType _bottomNavType = BottomNavigationBarType.fixed;

  @override
  void initState() {
    FlutterLocalNotification.init();
    FlutterLocalNotification.requestNotificationPermission();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: null,
        title: const Text(
          "헬미",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xff000000)),
        ),
        centerTitle: true,
      ),
      body: _getPageWidget(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xff0a46ff),
          unselectedItemColor: const Color(0xff757575),
          type: _bottomNavType,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: _bottomBarItems),
    );
  }

  Widget _getPageWidget(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const CalendarPage();
      case 2:
        return const TimerPage();
      case 3:
        return const SettingPage();
      default:
        return const HomePage();
    }
  }
}

const _bottomBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: '홈',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.calendar_month_outlined),
    activeIcon: Icon(Icons.calendar_month_rounded),
    label: '캘린더',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.timer_outlined),
    activeIcon: Icon(Icons.timer_rounded),
    label: '타이머',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.settings_outlined),
    activeIcon: Icon(Icons.settings),
    label: '설정',
  ),
];
