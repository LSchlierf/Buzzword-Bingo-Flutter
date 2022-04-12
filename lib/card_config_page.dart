import 'dart:math';

import 'package:buzzword_bingo/bingo_card.dart';
import 'package:buzzword_bingo/bingo_page.dart';
import 'package:flutter/material.dart';

class CardConfigPage extends StatefulWidget {
  const CardConfigPage(
      {Key? key,
      required this.cardName,
      required this.entries,
      required this.addGame})
      : super(key: key);

  final String cardName;
  final List<String> entries;
  final Function addGame;

  @override
  createState() => CardConfigPageState();
}

class CardConfigPageState extends State<CardConfigPage> {
  int _maxSizeWithoutFree = 0;
  int _maxSizeWithFree = 0;
  bool _isDifferent = true;
  List<int> sizes = List.empty(growable: true);
  bool _useFreeField = true;
  int _selectedSize = 3;

  @override
  void initState() {
    _maxSizeWithoutFree = sqrt(widget.entries.length).toInt();
    _maxSizeWithFree = sqrt((widget.entries.length + 1) % 2 == 1
            ? (widget.entries.length + 1)
            : (widget.entries.length))
        .toInt();
    _isDifferent =
        _maxSizeWithFree != _maxSizeWithoutFree && _maxSizeWithFree % 2 == 1;
    _selectedSize = _maxSizeWithFree;
    _useFreeField = _selectedSize.isOdd;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cardName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Available entries: ${widget.entries.length}',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Maximum size: ${_isDifferent ? '${_maxSizeWithoutFree}x$_maxSizeWithoutFree, or ${_maxSizeWithFree}x$_maxSizeWithFree with a free field in the middle.' : '${_maxSizeWithoutFree}x$_maxSizeWithoutFree'}',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Use free field',
                    style: TextStyle(fontSize: 20),
                  ),
                  Checkbox(
                    activeColor: Colors.blue,
                    value: _useFreeField,
                    onChanged: (newValue) {
                      setState(() {
                        _useFreeField = newValue!;
                        if (!_useFreeField &&
                                _isDifferent &&
                                _selectedSize == _maxSizeWithFree ||
                            _selectedSize.isEven) {
                          _selectedSize--;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Size",
                    style: TextStyle(fontSize: 20),
                  ),
                  DropdownButton(
                    value: _selectedSize,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedSize = value!;
                        if (_isDifferent && _selectedSize == _maxSizeWithFree) {
                          _useFreeField = true;
                        }
                        if (_selectedSize.isEven) _useFreeField = false;
                      });
                    },
                    items: List.generate(
                            _maxSizeWithFree - 2, (index) => index + 3)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                          value: value, child: Text(value.toString()));
                    }).toList(), //maxSizeWithFreeField
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                child: const Text('Let\'s go!'),
                onPressed: _startGame,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _startGame() {
    BingoCard card = BingoCard.createFromLines(
        widget.entries.toList(), _selectedSize, _useFreeField)!;
    widget.addGame.call(card, widget.cardName);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return BingoPage(card: card, setName: widget.cardName);
        },
      ),
    );
  }
}
