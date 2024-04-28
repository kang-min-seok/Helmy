import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'on_boarding_page.dart';
import 'design_setting_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isNotification = false;
  static String themeText = "기기 테마";

  @override
  void initState() {
    getThemeText();
    super.initState();
  }

  void getThemeText() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedThemeMode = prefs.getString('themeMode');

    if (savedThemeMode == null) {
      setState(() {
        themeText = "기기 테마";
      });
    } else if (savedThemeMode == "light") {
      setState(() {
        themeText = "밝은 테마";
      });
    } else if (savedThemeMode == "dark") {
      setState(() {
        themeText = "어두운 테마";
      });
    } else if (savedThemeMode == "system") {
      setState(() {
        themeText = "기기 테마";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text("설정",style: Theme.of(context).textTheme.displayLarge),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              children: [
                _SingleSection(
                  title: "환경",
                  children: [
                    _CustomListTile(
                        title: "테마",
                        icon: Icons.format_paint_outlined,
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DesignSettingPage()),
                          ).then((_) {
                            getThemeText();
                          });
                        },
                      trailing: Text(
                        themeText,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    _CustomListTile(
                        title: "타이머 알림",
                        icon: Icons.notifications_none_rounded,
                        trailing: Switch(
                            value: _isNotification,
                            onChanged: (value) {
                              setState(() {
                                _isNotification = value;
                              });
                            })),
                  ],
                ),
                const Divider(),
                _SingleSection(
                  children: [
                    _CustomListTile(
                        title: "사용설명",
                        icon: Icons.help_outline_rounded,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OnBoardingPage(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap, // onTap 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing,
      onTap: onTap, // onTap 할당
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _SingleSection({
    Key? key,
    this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(
          children: children,
        ),
      ],
    );
  }
}
