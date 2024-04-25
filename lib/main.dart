import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import './pages/home_page.dart';
import './pages/calendar_page.dart';
import './pages/timer_page.dart';
import './pages/setting_page.dart';
import './models/WorkoutRecord.dart'; // WorkoutRecord 모델 import
import 'notification.dart';
import 'themeCustom.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/on_boarding_page.dart';

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

  await initializeService();
  initializeDateFormatting().then((_) => runApp(const MyApp()));
  //runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  print("서비스 구성 및 시작");
  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print("onStart 호출됨");
  Timer? currentTimer;

  service.on('startTimer').listen((event) {
    print("타이머 실행");
    int duration = event?['duration'] as int;
    // 기존 타이머가 활성화되어 있으면 취소
    currentTimer?.cancel();

    // 새 타이머 시작
    currentTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      print("현재초: $duration");
      if (duration > 0) {
        duration--;
        service.invoke('update', {"seconds": duration});
        if (duration == 20) {
          FlutterLocalNotification.showNotification();
        }
      } else {
        FlutterLocalNotification.showExerciseStartNotification();
        timer.cancel();
        service.invoke('timerComplete', {});
      }
    });
  });

  service.on('stopTimer').listen((event) {
    // 타이머 취소
    print("이건 도냐?");
    currentTimer?.cancel();
  });
}

class MyApp extends StatefulWidget  {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  bool? isOnboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  void _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isOnboardingComplete == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()), // 초기화 중 로딩 인디케이터
        ),
      );
    }

    return MaterialApp(
      title: '헬미',
      themeMode: ThemeMode.system,
      theme: ThemeCustom.lightTheme,
      darkTheme: ThemeCustom.darkTheme,
      debugShowCheckedModeBanner: false,
      home: isOnboardingComplete! ? const BottomNavigation() : const OnBoardingPage(),
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
