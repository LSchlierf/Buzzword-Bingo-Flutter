import 'dart:math';

import 'package:buzzword_bingo/bingo_tile.dart';
import 'package:buzzword_bingo/free_bingo_tile.dart';

class BingoCard {
  List<List<BingoTile>> tiles;

  BingoCard._({required this.tiles});

  static BingoCard? createFromLines(
      List<String> entries, int size, bool addFree) {
    addFree &= size % 2 == 1;
    if (entries.length < size * size - (addFree ? 1 : 0)) return null;
    int position = size ~/ 2;
    List<List<BingoTile>> tiles = List.empty(growable: true);
    for (int i = 0; i < size; i++) {
      tiles.add(List.empty(growable: true));
      for (int j = 0; j < size; j++) {
        if (addFree && i == position && j == position) {
          tiles[i].add(FreeBingoTile());
        } else {
          String newEntry = entries.elementAt(
              Random(DateTime.now().microsecondsSinceEpoch)
                  .nextInt(entries.length));
          entries.remove(newEntry);
          tiles[i].add(BingoTile(text: newEntry));
        }
      }
    }
    return BingoCard._(tiles: tiles);
  }

  bool isFinished() {
    bool horizontal = true;
    bool vertical = true;
    bool diagonalA = true;
    bool diagonalB = true;
    for (int i = 0; i < tiles.length; i++) {
      for (int j = 0; j < tiles[i].length; j++) {
        if (!(vertical || horizontal)) break;
        horizontal &= tiles[i][j].isMarkedOff;
        vertical &= tiles[j][i].isMarkedOff;
      }
      if (vertical || horizontal) return true;
      vertical = true;
      horizontal = true;
      diagonalA &= tiles[i][i].isMarkedOff;
      diagonalB &= tiles[i][tiles.length - i - 1].isMarkedOff;
    }
    return diagonalA || diagonalB;
  }

  int size() {
    return tiles.length;
  }

  List<BingoTile> toList() {
    List<BingoTile> result = List.empty(growable: true);
    for (List list in tiles) {
      for (BingoTile tile in list) {
        result.add(tile);
      }
    }
    return result;
  }
}
