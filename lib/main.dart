import 'package:buzzword_bingo/main_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BingoApp());
}

class BingoApp extends StatelessWidget {
  const BingoApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buzzword Bingo',
      theme: ThemeData.dark(),
      home: MainPage(
        key: key,
        title: 'Buzzword Bingo',
      ),
    );
  }
}
