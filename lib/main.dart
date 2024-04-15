import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './pages/home_page.dart';
import './pages/calendar_page.dart';
import './pages/timer_page.dart';
import './pages/setting_page.dart';
import './models/WorkoutRecord.dart'; // WorkoutRecord 모델 import
import 'notification.dart';
import 'themeCustom.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Hive를 초기화
  Hive.registerAdapter(WorkoutRecordAdapter());
  Hive.registerAdapter(WorkoutTypeAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(SetAdapter());
  // 운동 내부 데이터
  await Hive.openBox<WorkoutRecord>('workoutRecords');
  await Hive.openBox<WorkoutType>('workoutTypes');
  await Hive.openBox<Exercise>('exercises');
  await Hive.openBox<Set>('sets');
  initializeDateFormatting().then((_) => runApp(const MyApp()));
  //runApp(const MyApp());
}



class MyApp extends StatefulWidget  {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '헬미',
      themeMode: ThemeMode.system,
      theme: ThemeCustom.lightTheme,
      darkTheme: ThemeCustom.darkTheme,
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
      // appBar: AppBar(
      //   elevation: 0,
      //   titleSpacing: 0,
      //   leading: null,
      //   title: const Text(
      //     "헬미",
      //     textAlign: TextAlign.center,
      //   ),
      //   centerTitle: true,
      // ),
      body: _getPageWidget(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
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
