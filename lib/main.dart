import 'package:flutter/material.dart';

import 'HomePage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) => new MaterialApp(
      title: 'BARD',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: new HomePage(),
    );
}
