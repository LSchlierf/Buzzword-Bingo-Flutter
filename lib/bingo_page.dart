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
  List<BingoTile> tiles = List.empty(growable: true);

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
      body: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: (widget.card.isFinished()
            ? (widget.card.size() + 2)
            : (widget.card.size() + 1)),
        itemBuilder: ((context, index) {
          if (index < widget.card.size()) {
            return Row(
              children: _makeContainerList(widget.card.tiles[index]),
            );
          }
          if (index == widget.card.size()) {
            return const Padding(
              padding: EdgeInsets.all(20),
            );
          }
          return const Center(
            child: Text(
              '🎊 Bingo! 🎊',
              style: TextStyle(fontSize: 20),
            ),
          );
        }),
      ),
    );
  }

  List<Container> _makeContainerList(List<BingoTile> tiles) {
    List<Container> result = List.empty(growable: true);
    for (BingoTile tile in tiles) {
      if (tile is FreeBingoTile) {
        result.add(
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.all(
                color: Colors.black,
              ),
            ),
            width: MediaQuery.of(context).size.width / widget.card.size(),
            height: MediaQuery.of(context).size.width / widget.card.size(),
            child: Icon(
              Icons.star,
              size:
                  MediaQuery.of(context).size.width / (2 * widget.card.size()),
            ),
          ),
        );
      } else {
        result.add(
          Container(
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
                ),
                width: MediaQuery.of(context).size.width / widget.card.size(),
                height: MediaQuery.of(context).size.width / widget.card.size(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Center(
                    child: Text(
                      tile.text,
                      // style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return result;
  }
}
