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

  final Map<int, Widget> _entryWidgets = <int, Widget>{};
  final Map<int, String> _entryStrings = <int, String>{};

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
          BingoSets.createSet(_newSetName!, _entryStrings.values.toList())
              .whenComplete(() {
            widget.reloadCallback.call();
          });
        });
      } else {
        BingoSets.createSet(_newSetName!, _entryStrings.values.toList())
            .whenComplete(() {
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
        title: Text('${_entryStrings.length} entries'),
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
          itemCount: max(_entryWidgets.length * 2, 1),
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
            return _entryWidgets.values.elementAt(index ~/ 2);
          },
        ),
      ),
    );
  }

  void _addTile(String text) {
    setState(() {
      Widget tile = _makeEntryTile(text, _tileID);
      _entryStrings.putIfAbsent(_tileID, () => text);
      _entryWidgets.putIfAbsent(_tileID, () => tile);
      _tileID++;
      anyChange = true;
    });
  }

  void _removeTile(int id) {
    setState(() {
      _entryStrings.remove(id);
      _entryWidgets.remove(id);
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
          Row(
            children: [
              IconButton(
                onPressed: () => _editEntry(id),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Entry'),
                      content: Text(
                          'Are you sure you want to delete the entry "${_entryStrings[id]!}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _removeTile(id);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
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
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _addEntry() {
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

  void _editEntry(int id) {
    _textFieldController.clear();
    _textFieldController.text = _entryStrings[id]!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
          ),
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              setState(() {
                _removeTile(id);
                _addEntry();
                Navigator.pop(context);
              });
            },
          ),
        ],
        content: TextField(
          maxLines: null,
          expands: false,
          autofocus: true,
          keyboardType: TextInputType.text,
          controller: _textFieldController,
          decoration: const InputDecoration(hintText: "Edit Entry"),
          onEditingComplete: () {
            setState(
              () {
                _removeTile(id);
                _addEntry();
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}
