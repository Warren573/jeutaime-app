import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.pink,
    scaffoldBackgroundColor: Colors.pink[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.pink,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.orange,
    ),
    fontFamily: 'ComicSans',
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.brown[800],
    scaffoldBackgroundColor: Colors.brown[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.brown,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: Colors.amber,
    ),
    fontFamily: 'Georgia',
  );
}
