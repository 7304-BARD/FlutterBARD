import 'package:FlutterBARD/misc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class _FillerText extends StatelessWidget {
  static final _fillerChar = String.fromCharCode(0x3030);

  final int height;
  final int width;
  const _FillerText({this.height, this.width});

  Widget build(BuildContext con) => new Column(
      children:
          range(height).map((_) => new Text(_fillerChar * width)).toList());
}

class _CardText extends StatelessWidget {
  final String playerName;
  const _CardText(this.playerName);

  Widget build(BuildContext con) => new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Padding(
              child: new Text(playerName),
              padding: const EdgeInsets.symmetric(vertical: 10.0)),
          const _FillerText(height: 4, width: 9),
        ],
      );
}

class _CardImage extends StatelessWidget {
  final String imageAsset;
  const _CardImage(this.imageAsset);

  Widget build(BuildContext con) => new Container(
      decoration: new BoxDecoration(
          border: new Border.all(color: const Color(0xff444444), width: 1.0)),
      child: new Image(width: 100.0, image: new AssetImage(imageAsset)));
}

class _FillerCard extends StatelessWidget {
  final Color background;
  final String name;
  final String imageAsset;
  const _FillerCard(
      {@required this.background,
      @required this.name,
      @required this.imageAsset});

  Widget build(BuildContext con) => new Container(
      decoration: new ShapeDecoration(
          color: background,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0))),
      child: new Padding(
          padding: const EdgeInsets.all(20.0),
          child: new Column(
            children: [
              new _CardImage(imageAsset),
              new _CardText(name),
            ],
          )));
}

class Logo extends StatelessWidget {
  const Logo();

  Widget build(BuildContext con) => new Column(
        children: [
          new Center(
              child: new Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: new Text(appTitle,
                      style: new TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(con).accentColor)))),
          const _FillerCard(
              name: "Buzz",
              imageAsset: "icons/mascot.png",
              background: Colors.lime),
        ],
      );
}
