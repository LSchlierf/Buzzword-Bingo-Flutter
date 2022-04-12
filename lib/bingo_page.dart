import 'dart:math';

import 'package:buzzword_bingo/free_bingo_tile.dart';
import 'package:flutter/material.dart';
import 'bingo_card.dart';
import 'bingo_tile.dart';

class BingoPage extends StatefulWidget {
  const BingoPage({Key? key, required this.card, required this.setName})
      : super(key: key);

  final BingoCard card;
  final String setName;

  @override
  createState() => BingoPageState();
}

class BingoPageState extends State<BingoPage> {
  //TODO: add animation on win
  List<BingoTile> tiles = List.empty(growable: true);
  double _cardWidth = 0;

  static const double _borderRadius = 10.0;
  static const double _borderGap = 2.0;

  @override
  initState() {
    tiles = widget.card.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.setName} Bingo'),
        centerTitle: true,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          _cardWidth = min(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height -
                      Scaffold.of(context).appBarMaxHeight!)
              .toDouble();
          return orientation == Orientation.portrait
              ? Column(
                  children: _makeCardLayoutList(),
                )
              : Row(
                  children: _makeCardLayoutList(),
                );
        },
      ),
    );
  }

  List<Widget> _makeCardLayoutList() {
    return <Widget>[
          SizedBox(
            height: _cardWidth,
            width: _cardWidth,
            child: _makeBingoCardWidget(widget.card),
          ),
        ] +
        (widget.card.isFinished()
            ? [
                const Expanded(
                  child: Center(
                    child: Text(
                      '🎊 Bingo! 🎊',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ]
            : []);
  }

  Widget _makeBingoCardWidget(BingoCard card) {
    return GridView.count(
      crossAxisCount: card.size(),
      shrinkWrap: true,
      children: _makeWidgetList(card.toList()),
    );
  }

  List<Widget> _makeWidgetList(List<BingoTile> tiles) {
    List<Widget> result = List.empty(growable: true);
    for (BingoTile tile in tiles) {
      if (tile is FreeBingoTile) {
        result.add(_makeFreeTileWidget(tile));
      } else {
        result.add(_makeTileWidget(tile));
      }
    }
    return result;
  }

  Widget _makeTileWidget(BingoTile tile) {
    return Container(
      padding: const EdgeInsets.all(_borderGap),
      child: GestureDetector(
        onTap: () {
          setState(() {
            tile.isMarkedOff = !tile.isMarkedOff;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: (tile.isMarkedOff ? Colors.green : null),
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Center(
              child: Text(
                tile.text,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _makeFreeTileWidget(BingoTile tile) {
    return Container(
      padding: const EdgeInsets.all(_borderGap),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Icon(
          Icons.star,
          size: _cardWidth / (2 * widget.card.size()),
        ),
      ),
    );
  }
}
