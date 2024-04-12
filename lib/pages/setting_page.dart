import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('세팅 페이지', style: Theme.of(context).textTheme.headline4),
    );
  }
}
