import 'package:buzzword_bingo/main_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(BingoApp());
}

class BingoApp extends StatelessWidget {
  BingoApp({Key? key}) : super(key: key);
  final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
  );
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Buzzword Bingo',
        theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            brightness: Brightness.dark,
            secondary: Colors.blue,
          ),
        ),
        home: MainPage(
          key: key,
          title: 'Buzzword Bingo',
        ),
        debugShowCheckedModeBanner: false,
      );
}
