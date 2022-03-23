import 'dart:math';

import 'package:buzzword_bingo/bingo_sets.dart';
import 'package:flutter/material.dart';

class EditSetPage extends StatefulWidget {
  const EditSetPage(
      {Key? key,
      this.oldSetName,
      this.oldSetEntries,
      required this.reloadCallback})
      : super(key: key);

  final Function reloadCallback;
  final String? oldSetName;
  final List<String>? oldSetEntries;

  @override
  createState() => EditSetPageState();
}

class EditSetPageState extends State<EditSetPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textFieldController = TextEditingController();
  bool _isTitle = false;
  bool anyChange = false;
  final List<Widget> _entries = List.empty(growable: true);
  final List<String> _entryTexts = List.empty(growable: true);
  final List<int> _entryIDs = List.empty(growable: true);
  String? _newSetName;
  int _tileID = 0;
  ScrollController sc = ScrollController();

  @override
  void initState() {
    super.initState();
    _tileID = 0;
    if (widget.oldSetName != null) {
      _titleController.text = widget.oldSetName!;
    }
    if (widget.oldSetEntries != null) {
      for (String text in widget.oldSetEntries!) {
        _addTile(text);
      }
    }
    _updateTitle();
    _titleController.addListener(() {
      _updateTitle();
    });
  }

  @override
  void deactivate() {
    if (_isTitle && anyChange) {
      _newSetName = _titleController.value.text;
      if (widget.oldSetName != null) {
        BingoSets.deleteSet(widget.oldSetName!).then((value) {
          BingoSets.createSet(_newSetName!, _entryTexts).whenComplete(() {
            widget.reloadCallback.call();
          });
        });
      } else {
        BingoSets.createSet(_newSetName!, _entryTexts).whenComplete(() {
          widget.reloadCallback.call();
        });
      }
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_entryTexts.length} entries'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                _displayTextInputDialog(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Center(
        child: ListView.builder(
          controller: sc,
          padding: const EdgeInsets.all(15),
          itemCount: max(_entries.length * 2, 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: TextField(
                  style: const TextStyle(fontSize: 20),
                  controller: _titleController,
                  decoration: InputDecoration(
                      errorText: _isTitle ? null : 'Title is required',
                      border: const OutlineInputBorder(),
                      hintText: 'Enter a title'),
                  onChanged: (value) {
                    anyChange = true;
                  },
                ),
              );
            }
            if (index.isEven) return const Divider();
            final int i = index ~/ 2;
            return _entries[i];
          },
        ),
      ),
    );
  }

  void _addTile(String text) {
    setState(() {
      Widget tile = _makeEntryTile(text, _tileID);
      _entries.add(tile);
      _entryIDs.add(_tileID);
      _entryTexts.add(text);
      _tileID++;
      anyChange = true;
    });
  }

  void _removeTile(int id) {
    setState(() {
      final int index = _entryIDs.indexOf(id);
      _entries.removeAt(index);
      _entryIDs.removeAt(index);
      _entryTexts.removeAt(index);
      anyChange = true;
    });
  }

  void _updateTitle() {
    setState(() {
      _isTitle = _titleController.text.trim().isNotEmpty;
    });
  }

  Widget _makeEntryTile(String text, int id) {
    return GestureDetector(
      onLongPress: () => _removeTile(id),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.left,
            ),
          ),
          IconButton(
              onPressed: () => _removeTile(id), icon: const Icon(Icons.delete))
        ],
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    _textFieldController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Entry'),
          content: TextField(
            autofocus: true,
            expands: false,
            maxLines: null,
            keyboardType: TextInputType.text,
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Enter new Entry"),
            onEditingComplete: () {
              setState(
                () {
                  _addEntry();
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                setState(
                  () {
                    Navigator.pop(context);
                  },
                );
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                setState(
                  () {
                    _addEntry();
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  _addEntry() {
    String text = _textFieldController.value.text.trim();
    if (text.isNotEmpty) {
      for (String entry in text.split("\n")) {
        entry = entry.trim();
        if (entry.isNotEmpty) _addTile(entry);
      }
    }
    sc.animateTo(sc.position.maxScrollExtent,
        duration: const Duration(seconds: 2), curve: Curves.ease);
  }
}
