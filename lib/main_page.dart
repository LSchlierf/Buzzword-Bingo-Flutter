import 'package:buzzword_bingo/bingo_card.dart';
import 'package:buzzword_bingo/bingo_page.dart';
import 'package:buzzword_bingo/bingo_sets.dart';
import 'package:buzzword_bingo/card_config_page.dart';
import 'package:buzzword_bingo/imprint.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'edit_set_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final Map<int, Container> _setContainers = <int, Container>{};
  final Map<int, String> _setNames = <int, String>{};
  final Map<int, Container> _gameContainers = <int, Container>{};
  final Map<int, BingoCard> _games = <int, BingoCard>{};

  int _setID = 0;
  int _gameID = 0;

  @override
  void initState() {
    super.initState();
    _loadAllSets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Imprint(),
              ),
            ),
            icon: const Icon(Icons.info_outline),
          ),
          title: Text(widget.title),
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.add,
                ),
                onPressed: () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(builder: ((context) {
                    return EditSetPage(reloadCallback: _loadAllSets);
                  }))).whenComplete(_loadAllSets);
                })
          ],
        ),
        body: ListView.builder(
            itemCount: max(
                (_setContainers.length + _gameContainers.length) * 2 - 1, 0),
            itemBuilder: (context, index) {
              if (index.isOdd) return const Divider();
              return (_gameContainers.values.toList() +
                  _setContainers.values.toList())[index ~/ 2];
            }));
  }

  Container _makeSetTile(String setName, int id) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: GestureDetector(
        onTap: () => _playSet(id),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                setName,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () => _deleteSet(id),
                    icon: const Icon(Icons.delete)),
                IconButton(
                    onPressed: () => _editSet(id),
                    icon: const Icon(Icons.edit)),
                IconButton(
                    onPressed: () => _playSet(id),
                    icon: const Icon(Icons.keyboard_arrow_right)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _loadAllSets() async {
    List<String> setNames = await BingoSets.allSets;
    for (String name in setNames) {
      if (!_setNames.containsValue(name)) {
        setState(() {
          _reloadAllSets(setNames);
        });
        return;
      }
    }
    for (String name in _setNames.values) {
      if (!setNames.contains(name)) {
        setState(() {
          _reloadAllSets(setNames);
        });
        break;
      }
    }
  }

  void _addSet(String name) {
    _setContainers.putIfAbsent(_setID, () => _makeSetTile(name, _setID));
    _setNames.putIfAbsent(_setID, () => name);
    _setID++;
  }

  void _reloadAllSets(List<String> names) {
    _setContainers.clear();
    _setNames.clear();
    for (String name in names) {
      _addSet(name);
    }
  }

  Future<void> _playSet(int id) async {
    String setName = _setNames[id]!;
    List<String>? entries = await BingoSets.getSet(setName);
    bool none = entries == null || entries.isEmpty;
    if (entries == null || entries.length < 9) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Not enough entries'),
              content: Text(
                  'The set "$setName" has ${none ? 'no' : 'not enough'} entries, try adding some ${none ? '' : 'more '}to the set.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Okay'))
              ],
            );
          });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return CardConfigPage(
              cardName: setName,
              entries: entries,
              addGame: _addGame,
            );
          },
        ),
      );
    }
  }

  Future<void> _editSet(int id) async {
    String setName = _setNames[id]!;
    List<String>? entries = await BingoSets.getSet(setName);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return EditSetPage(
            reloadCallback: _loadAllSets,
            oldSetEntries: entries,
            oldSetName: setName,
          );
        },
      ),
    );
  }

  Future<void> _deleteSet(int id) async {
    String setName = _setNames[id]!;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete set'),
          content: Text('Are you sure you want to delete the set "$setName"?'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                BingoSets.deleteSet(setName).whenComplete(_loadAllSets);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            )
          ],
        );
      },
    );
  }

  void _addGame(BingoCard game, String setName) {
    setState(() {
      _games.putIfAbsent(_gameID, () => game);
      _gameContainers.putIfAbsent(
          _gameID, () => _makeGameTile(game, setName, _gameID));
      _gameID++;
    });
  }

  Container _makeGameTile(BingoCard game, String name, int id) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => BingoPage(card: game, setName: name)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Resume: $name, size ${game.size()}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _deleteGame(id),
                  icon: const Icon(Icons.cancel_outlined),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGame(int id) {
    setState(() {
      _gameContainers.remove(id);
      _games.remove(id);
    });
  }
}
