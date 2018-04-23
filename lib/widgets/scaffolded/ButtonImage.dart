import 'dart:async';
import 'dart:io';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:FlutterBARD/widgets/scaffolded/Image.dart'
class ButtonImage extends StatefulWidget {
  final int pictureCount;
  ButtonImage(this.pictureCount);
  @override
  _ButtonImageState createState() => new _ButtonImageState();

}
class _ButtonImageState extends State<ButtonImage> {
  String imagePath;

  @override
  Widget build(BuildContext context) {
    int pictureCount = widget.pictureCount;
    capture(pictureCount);
    var assetImage = new AssetImage(imagePath);
    var image = new Image(image: assetImage, height: 64.0, width: 64.0);
    return new Container(
      height: image.height,
      width: image.width,
      child: new FlatButton(
        onPressed: tapNav(
                (BuildContext con) => new Picture(imagePath),
            con,
              ButtonImage(pictureCount)
            )
        child: new ConstrainedBox(
          constraints: new BoxConstraints.expand(),
          child: image,
        ),
      ),
    );
  }






  Future<Null> capture(int pictureCount) async {
    final Directory tempDir = await getApplicationDocumentsDirectory();
    final String tempPath = tempDir.path;
    final String path = '$tempPath/picture${pictureCount++}.jpg';
    setState(
            () {
          imagePath = path;
        },
    );
}



