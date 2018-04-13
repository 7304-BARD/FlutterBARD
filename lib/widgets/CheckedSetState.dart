import 'package:flutter/material.dart';

abstract class CheckedSetState<T extends StatefulWidget> extends State<T> {
  // From the documentation for State.setState:
  // "It is an error to call this method after the framework calls dispose.
  // You can determine whether it is legal to call this method by
  // checking whether the mounted property is true."
  void setState(VoidCallback cb) {
    if (mounted) super.setState(cb);
  }
}
