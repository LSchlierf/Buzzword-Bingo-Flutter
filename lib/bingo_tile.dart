import 'package:flutter/material.dart';

class BingoTile {
  bool isMarkedOff = false;
  String text;
  BingoTile({required this.text});
  Container getDisplayTile() {
    return Container(
      child: Center(
        child: Column(
          children: [
            Text(text),
            Checkbox(
                value: isMarkedOff,
                onChanged: (newValue) {
                  isMarkedOff = newValue!;
                })
          ],
        ),
      ),
    );
  }
}
