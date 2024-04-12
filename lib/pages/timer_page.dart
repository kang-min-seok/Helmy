import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../notification.dart';
class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  Timer? _timer;
  AnimationController? _controller;
  static int minuteSetting = 0;
  static int secondSetting = 5;
  int seconds = (60 * minuteSetting) + secondSetting;
  int maxSeconds = (60 * minuteSetting) + secondSetting;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: maxSeconds),
      vsync: this,
    );
  }

  void _startTimer() {

    setState(() {
      _isRunning = true;
      _isCompleted = false;
      seconds = maxSeconds;
    });
    _controller?.forward(from: 0);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        if(maxSeconds > 25 && seconds == 20){
          FlutterLocalNotification.showNotification();
        }
        setState(() {
          seconds--;
        });
      } else {
        FlutterLocalNotification.showExerciseStartNotification();
        _timer?.cancel();
        setState(() {
          _isCompleted = true;
          _controller?.reset();
        });
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      seconds = maxSeconds;
      _controller?.reset();
      _isRunning = false;
      _isCompleted = false;
    });
  }

  void _showTimeSettingModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 32.0,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              minuteSetting = index;
                            });
                          },
                          children: List<Widget>.generate(60, (int index) {
                            return Center(
                              child: Text('$index'),
                            );
                          }),
                          scrollController: FixedExtentScrollController(
                            initialItem: minuteSetting,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 32.0,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              secondSetting = index;
                            });
                          },
                          children: List<Widget>.generate(60, (int index) {
                            return Center(
                              child: Text('$index'),
                            );
                          }),
                          scrollController: FixedExtentScrollController(
                            initialItem: secondSetting,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _setTimer();
                  },
                  child: Text('설정'),
                )
              ],
            ),
          );
        }
    );
  }

  // 새로운 시간 설정을 기반으로 타이머를 리셋하는 함수입니다.
  void _setTimer() {
    final newMaxSeconds = (60 * minuteSetting) + secondSetting;
    setState(() {
      maxSeconds = newMaxSeconds;
      seconds = newMaxSeconds;
      _controller?.duration = Duration(seconds: newMaxSeconds);
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timerText = _isCompleted
        ? "쉬는 시간\n시작"
        : "${seconds ~/ 60} : ${(seconds % 60).toString().padLeft(2, '0')}";

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _isCompleted ? _startTimer : _isRunning ? null : _showTimeSettingModal,
              child: AnimatedBuilder(
                animation: _controller!,
                builder: (context, child) => SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _controller!.value,
                        valueColor: AlwaysStoppedAnimation(Color(0xFFDEDEDE)),
                        strokeWidth: 12,
                        backgroundColor: _isCompleted ? Colors.red : const Color(0xFF0A46FF),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          timerText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: _isCompleted ? 25 : 50,
                            fontWeight: FontWeight.bold,
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
                  backgroundColor: const Color(0xFF0A46FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
