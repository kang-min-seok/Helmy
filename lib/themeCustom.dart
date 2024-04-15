import 'package:flutter/material.dart';

class ThemeCustom {
  static ThemeData lightTheme = ThemeData(
    fontFamily: "Dohyeon",
    useMaterial3: true,
    dividerColor: Colors.transparent,
    primaryColor: const Color.fromARGB(255, 38, 38, 38),
    primaryColorDark: const Color.fromARGB(255, 118, 156, 220),
    primaryColorLight: const Color.fromARGB(255, 217, 235, 255),
    shadowColor: const Color.fromARGB(255, 87, 87, 87).withOpacity(0.3),
    canvasColor: const Color.fromARGB(255, 255, 255, 255),
      textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 27,
          ),
          displayMedium: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          displaySmall: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          )
      ),
    colorScheme: const ColorScheme(
      background: Color.fromARGB(255, 255, 255, 255),
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 49, 130, 247),
      onPrimary: Color.fromARGB(255, 255, 255, 255),
      secondary: Color.fromARGB(255, 118, 156, 220),
      onSecondary: Color.fromARGB(255, 217, 235, 255),
      error: Colors.red,
      onError: Colors.white,
      onBackground: Color.fromARGB(255, 0, 0, 0),
      surface: Color(0xFFEFEFEF),
      onSurface: Color.fromARGB(255, 0, 0, 0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // New default background color
        backgroundColor: const Color.fromARGB(255, 49, 130, 247), // New default text color
      ),
    ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: Colors.black,
      )
  );
  static ThemeData darkTheme = ThemeData(
    fontFamily: "Dohyeon",
    useMaterial3: true,
    dividerColor: Colors.transparent,
    primaryColor: Colors.white,
    primaryColorDark: const Color.fromARGB(255, 118, 156, 220),
    primaryColorLight: const Color.fromARGB(255, 145, 157, 170),
    shadowColor: const Color.fromARGB(255, 173, 173, 173).withOpacity(0.3),
    canvasColor: const Color.fromARGB(255, 38, 38, 38),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 27,
      ),
      displayMedium: TextStyle(
        color: Color.fromARGB(255, 195, 195, 195),
      ),
      displaySmall: TextStyle(
        color: Color.fromARGB(255, 195, 195, 195),
      )
    ),
    colorScheme: ColorScheme(
      background: const Color.fromARGB(255, 26, 26, 26),
      brightness: Brightness.dark,
      // primary: Colors.white,
      primary: const Color.fromARGB(255, 49, 130, 247),
      onPrimary: const Color.fromARGB(255, 38, 38, 38),
      secondary: Colors.white,
      onSecondary: const Color.fromARGB(255, 49, 130, 247),
      error: Colors.red[700]!,
      onError: Colors.black,
      onBackground: const Color.fromARGB(255, 195, 195, 195),
      surface: const Color.fromARGB(255, 50, 50, 50),
      onSurface: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // New default background color
        backgroundColor: const Color.fromARGB(255, 49, 130, 247), // New default text color
      ),
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      iconColor: Colors.white,
    )
  );
}
