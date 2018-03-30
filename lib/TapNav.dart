import 'package:meta/meta.dart';

import 'package:flutter/material.dart';

tapNav(WidgetBuilder builder, BuildContext con, [Function onDismissed]) => () {
      Navigator
          .of(con)
          .push(new MaterialPageRoute<Null>(builder: builder))
          .whenComplete(onDismissed ?? () {});
    };

class TapNav<T> extends StatelessWidget {
  final WidgetBuilder builder;
  final Function onDismissed;
  final Widget child;
  TapNav({@required this.builder, this.onDismissed, @required this.child});

  Widget build(BuildContext con) => new GestureDetector(
      onTap: tapNav(builder, con, onDismissed), child: child);
}
