import 'package:buzzword_bingo/bingo_tile.dart';

class FreeBingoTile extends BingoTile {
  FreeBingoTile() : super(text: 'FREE');

  @override
  // TODO: implement isMarkedOff
  bool get isMarkedOff => true;
}
