import 'package:FlutterBARD/values/Player.dart';
import 'package:FlutterBARD/widgets/TapNav.dart';
import 'package:FlutterBARD/widgets/scaffolded/PlayerDetail.dart';
import 'package:flutter/material.dart';

void nop() {}

// For Player data in a list.
// Responds to a tap by pushing a new PlayerDetail.
class PlayerListElement extends StatelessWidget {
  final Player player;
  final Function
      onDismissed; // optional callback invoked when the PlayerDetail is popped.

  const PlayerListElement(this.player, [this.onDismissed = nop]);

  Widget build(BuildContext con) => new TapNav(
      builder: (BuildContext con) => new PlayerDetail(player),
      onDismissed: (onDismissed),
      child: new Row(
        children: [
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text(player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          new Text(player.pos),
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text(player.year),
          ),
        ],
      ));
}
