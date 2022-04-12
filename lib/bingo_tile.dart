import 'package:buzzword_bingo/bingo_card.dart';

class BingoTile {
  bool isMarkedOff = false;
  String text;
  BingoTile({required this.text});
  int isCorner(BingoCard card) {
    if (card.tiles.first.first == this) return 1;
    if (card.tiles.first.last == this) return 2;
    if (card.tiles.last.first == this) return 3;
    if (card.tiles.last.last == this) return 4;
    return 0;
  }
}
