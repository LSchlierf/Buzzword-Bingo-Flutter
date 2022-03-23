import 'package:buzzword_bingo/bingo_tile.dart';

class FreeBingoTile extends BingoTile {
  FreeBingoTile() : super(text: 'FREE');

  @override
  bool get isMarkedOff => true;
}
