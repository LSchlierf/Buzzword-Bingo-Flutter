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
  final List<Container> _setTiles = List.empty(growable: true);
  final List<String> _availableNames = List.empty(growable: true);
  final List<int> _setIndices = List.empty(growable: true);
  int _tileID = 0;

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
                    return EditSetPage(reloadCallback: () => _loadAllSets());
                  }))).whenComplete(() => _loadAllSets());
                })
          ],
        ),
        body: ListView.builder(
            itemCount: max(_setTiles.length * 2 - 1, 0),
            itemBuilder: (context, index) {
              if (index.isOdd) return const Divider();
              return _setTiles[index ~/ 2];
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
      if (!_availableNames.contains(name)) {
        setState(() {
          _reloadAllTiles(setNames);
        });
        return;
      }
    }
    for (String name in _availableNames) {
      if (!setNames.contains(name)) {
        setState(() {
          _reloadAllTiles(setNames);
        });
        break;
      }
    }
  }

  void _addTile(String name) {
    _availableNames.add(name);
    _setIndices.add(_tileID);
    _setTiles.add(_makeSetTile(name, _tileID));
    _tileID++;
  }

  void _reloadAllTiles(List<String> names) {
    _availableNames.clear();
    _setTiles.clear();
    _setIndices.clear();
    for (String name in names) {
      _addTile(name);
    }
  }

  Future<void> _playSet(int id) async {
    String setName = _availableNames.elementAt(_setIndices.indexOf(id));
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
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return CardConfigPage(cardName: setName, entries: entries);
      }));
    }
  }

  Future<void> _editSet(int id) async {
    String setName = _availableNames.elementAt(_setIndices.indexOf(id));
    List<String>? entries = await BingoSets.getSet(setName);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return EditSetPage(
          reloadCallback: () => _loadAllSets(),
          oldSetEntries: entries,
          oldSetName: setName,
        );
      },
    ));
  }

  Future<void> _deleteSet(int id) async {
    String setName = _availableNames.elementAt(_setIndices.indexOf(id));
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete set'),
            content:
                Text('Are you sure you want to delete the set "$setName"?'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    BingoSets.deleteSet(setName)
                        .whenComplete(() => _loadAllSets());
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'))
            ],
          );
        });
  }
}
