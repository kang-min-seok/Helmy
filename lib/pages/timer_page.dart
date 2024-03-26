import 'package:flutter/material.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('타이머 페이지', style: Theme.of(context).textTheme.headline4),
    );
  }
}
