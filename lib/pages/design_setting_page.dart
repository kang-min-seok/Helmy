import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme_provider.dart';

class DesignSettingPage extends StatefulWidget {
  const DesignSettingPage({Key? key}) : super(key: key);

  @override
  State<DesignSettingPage> createState() => _DesignSettingPageState();
}

class _DesignSettingPageState extends State<DesignSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("설정", style: Theme.of(context).textTheme.displayLarge),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              _SingleSection(
                title: "디자인",
                children: [
                  _CustomListTile(
                    title: "기기 테마 사용",
                    icon: Icons.perm_device_info_rounded,
                    onTap: () {
                      final themeProvider =
                          Provider.of<ThemeProvider>(context, listen: false);
                      themeProvider.setThemeMode(ThemeMode.system);
                      Navigator.pop(context);
                    },
                  ),
                  _CustomListTile(
                    title: "어두운 테마",
                    icon: Icons.dark_mode_outlined,
                    onTap: () {
                      final themeProvider =
                          Provider.of<ThemeProvider>(context, listen: false);
                      themeProvider.setThemeMode(ThemeMode.dark);
                      Navigator.pop(context);
                    },
                  ),
                  _CustomListTile(
                    title: "밝은 테마",
                    icon: Icons.light_mode_outlined,
                    onTap: () {
                      final themeProvider =
                          Provider.of<ThemeProvider>(context, listen: false);
                      themeProvider.setThemeMode(ThemeMode.light);
                      Navigator.pop(context);
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
