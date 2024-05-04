import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  AnimationController? _controller;
  static int minuteSetting = 2;
  static int secondSetting = 0;
  static int seconds = (60 * minuteSetting) + secondSetting;
  int maxSeconds = (60 * minuteSetting) + secondSetting;
  static bool _isRunning = false;
  static bool _isCompleted = false;
  final service = FlutterBackgroundService();
  static int tempSecond = seconds;
  late final bool savedIsNotification;
  static StreamSubscription? updateSubscription;
  static StreamSubscription? completeSubscription;

  @override
  void initState() {
    super.initState();
    getIsNotification();
    updateSubscription?.cancel();
    completeSubscription?.cancel();
    updateSubscription = service.on('update').listen((event) {
      final secs = event!['seconds'];
      tempSecond = secs;
      if (!mounted) return;
      if (secs != null) {
        setState(() {
          seconds = secs;
        });
      }
    });
    completeSubscription = service.on('timerComplete').listen((event) {
      if (!mounted) return;
      setState(() {
        _isCompleted = true;
        _controller?.reset();
      });

    });

    setState(() {
      if (_isRunning) {
        seconds = tempSecond;
      } else {
        seconds = maxSeconds;
      }
    });

    _controller = AnimationController(
      duration: Duration(seconds: maxSeconds),
      vsync: this,
    );
  }

  void getIsNotification() async {
    final pref = await SharedPreferences.getInstance();
    savedIsNotification = pref.getBool('isNotification') ?? true;
  }

  void _startTimer() {
    setState(() {
      seconds = maxSeconds;
      _isRunning = true;
      _isCompleted = false;
    });
    _controller?.forward(from: 0);
    service.invoke('startTimer', {
      'duration': maxSeconds,
      'isNotification': savedIsNotification,
    });
  }

  void _resetTimer() {
    setState(() {
      seconds = maxSeconds;
      _isRunning = false;
      _isCompleted = false;
    });
    _controller?.reset();
    service.invoke('stopTimer');
  }

  void _setTimer() {
    final newMaxSeconds = (60 * minuteSetting) + secondSetting;
    setState(() {
      maxSeconds = newMaxSeconds;
      seconds = newMaxSeconds;
    });
    _controller = AnimationController(
      duration: Duration(seconds: maxSeconds),
      vsync: this,
    );
  }

  void _showTimeSettingModal() {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery
              .of(context)
              .copyWith()
              .size
              .height / 3,
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 20),
          child: Column(
            children: <Widget>[
          Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // "분" 레이블을 고정합니다.
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.only(right: 40),
                        child: Text('분'),
                      ),
                    ),
                    CupertinoPicker(
                      itemExtent: 32.0,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          minuteSetting = index;
                        });
                      },
                      children: List<Widget>.generate(11, (int index) {
                        return Center(child: Text('$index'));
                      }),
                      scrollController: FixedExtentScrollController(
                        initialItem: minuteSetting,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // "초" 레이블을 고정합니다.
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.only(right: 40),
                        child: Text('초'),
                      ),
                    ),
                    CupertinoPicker(
                      itemExtent: 32.0,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          secondSetting = index;
                        });
                      },
                      children: List<Widget>.generate(60, (int index) {
                        return Center(child: Text('$index'));
                      }),
                      scrollController: FixedExtentScrollController(
                        initialItem: secondSetting,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
                Container(
                  width: double.infinity, // Container의 너비를 무한대로 설정하여 가로를 꽉 채웁니다.
                  child:ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _setTimer();
                    },
                    child: const Text('설정'),
                  ),
                ),

              ],
            ),
          );
        },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timerText = _isCompleted
        ? "쉬는 시간\n시작"
        : "${seconds ~/ 60} : ${(seconds % 60).toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("타이머",style: Theme.of(context).textTheme.displayLarge),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _isCompleted ? _startTimer : _isRunning
                  ? null
                  : _showTimeSettingModal,
              child: AnimatedBuilder(
                animation: _controller!,
                builder: (context, child) =>
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: _controller!.value,
                            valueColor: const AlwaysStoppedAnimation(Color(
                                0xFFDEDEDE)),
                            strokeWidth: 12,
                            backgroundColor: _isCompleted
                                ? Colors.red
                                : const Color.fromARGB(255, 49, 130, 247),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              timerText,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: _isCompleted ? 25 : 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
            SizedBox(height: 50),
            if (!_isRunning && !_isCompleted)
              ElevatedButton(
                onPressed: _startTimer,
                child: Text('운동 시작'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 49, 130, 247),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_isRunning)
              ElevatedButton(
                onPressed: _resetTimer,
                child: Text('운동 종료'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
