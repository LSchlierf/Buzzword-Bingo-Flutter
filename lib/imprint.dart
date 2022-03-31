import 'package:flutter/material.dart';

class Imprint extends StatelessWidget {
  const Imprint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imprint'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: const [
            Text('Copyright 2022 Lucas Schlierf'),
            Text('Contact:'),
            Text('LucasSchlierf@Gmail.com'),
          ],
        ),
      ),
    );
  }
}
