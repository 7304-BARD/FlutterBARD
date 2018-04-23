import 'dart:async';
import 'dart:io';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart';
class Picture extends StatefulWidget {
  final String ImageName;
  Picture(this.ImageName);
  @override
  _ImageState createState() => new _ImageState();

}

class _ImageState extends State<Image> {
  @override
  Widget build(BuildContext context) {
  new Image.asset(ImageName, fit:BoxFit.cover);
}