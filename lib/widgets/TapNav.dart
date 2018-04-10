import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

tapNav(WidgetBuilder builder, BuildContext con, [Function onDismissed]) => () {
      Navigator
          .of(con)
          .push(new MaterialPageRoute<Null>(builder: builder))
          .whenComplete(onDismissed ?? () {});
    };

class TapNav extends StatelessWidget {
  final WidgetBuilder builder;
  final Function onDismissed;
  final Widget child;
  const TapNav(
      {@required this.builder, this.onDismissed, @required this.child});

  Widget build(BuildContext con) => new GestureDetector(
      onTap: tapNav(builder, con, onDismissed), child: child);
}
