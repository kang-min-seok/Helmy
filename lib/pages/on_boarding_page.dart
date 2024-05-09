import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:helmy/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
            title: '운동을 찾을 필요 없이\n텍스트로 기록하세요!',
            body: '부위, 운동, 무게는 버튼을 통해 추가하고\n슬라이드를 통해 추가한 운동을\n삭제할 수 있습니다.',
            image: Image.asset('assets/images/onBoarding2.png'),
            decoration:  PageDecoration(
              pageMargin: EdgeInsets.fromLTRB(10, 100, 10, 50),
              imageFlex: 2,
              pageColor: Theme.of(context).colorScheme.background,
              bodyAlignment: Alignment.center,
            )
        ),
        PageViewModel(
            title: '캘린더로 한눈에!',
            body: '추가된 운동기록을 캘린더를 통해\n한눈에 살펴볼 수 있습니다',
            image: Image.asset('assets/images/onBoarding3.png'),
            decoration:  PageDecoration(
              pageMargin: EdgeInsets.fromLTRB(10, 100, 10, 50),
              imageFlex: 2,
              pageColor: Theme.of(context).colorScheme.background,
              bodyAlignment: Alignment.center,
            )
        ),
        PageViewModel(
            title: '휴식시간을 타이머로 조절해보세요',
            body: '준비할 때와 시작할 때 알림을 드립니다.\n운동이 끝나고 타이머 중앙을 탭하면\n다시 휴식을 시작할 수 있습니다',
            image: Image.asset('assets/images/onBoarding4.png'),
            decoration:  PageDecoration(
              pageMargin: EdgeInsets.fromLTRB(10, 100, 10, 50),
              imageFlex: 2,
              pageColor: Theme.of(context).colorScheme.background,
              bodyAlignment: Alignment.center,
            )
        ),
        PageViewModel(
            title: '복잡 X 간편 O',
            body: '복잡한 기능은 다 빼고 최대한 간편하게 만든\n헬스 기록 메모장 어플입니다.\n근성장을 향해 달려봅시다!',
            image: Image.asset('assets/images/onBoarding1.png'),
            decoration: PageDecoration(
              pageMargin: EdgeInsets.fromLTRB(10, 100, 10, 50),
              imageFlex: 2,
              pageColor: Theme.of(context).colorScheme.background,
              bodyAlignment: Alignment.center,
            )
        ),
      ],
      done: const Text('start!'),
      onDone: ()async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_complete', true);

        ThemeMode themeMode = ThemeMode.system;
        final String? savedThemeMode = prefs.getString('themeMode');

        if (savedThemeMode == null) {
          themeMode = ThemeMode.system;
        } else if (savedThemeMode == "light") {
          themeMode = ThemeMode.light;
        } else if (savedThemeMode == "dark") {
          themeMode = ThemeMode.dark;
        } else if (savedThemeMode == "system") {
          themeMode = ThemeMode.system;
        }


        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp(themeMode: themeMode)),
              (Route<dynamic> route) => false,
        );
      },
      next: const Icon(Icons.arrow_forward_ios),
      showSkipButton: true,
      skip: const Text('skip'),
      dotsDecorator: DotsDecorator(
        color: Theme.of(context).primaryColorLight,
        activeColor: Theme.of(context).primaryColor,
        size: const Size(6, 6),
        activeSize: Size(10, 10),
        spacing: EdgeInsets.all(10),
        activeShape: // shape 및 round 설정
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );

  }
}