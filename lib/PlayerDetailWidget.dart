import 'package:flutter/material.dart';

import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Player.dart';
import 'PlayerCache.dart';
import 'PlayerNoteEntry.dart';
import 'TapNav.dart';

class KVText extends StatelessWidget {
  final Tuple2<String, String> pair;

  KVText(this.pair);
  Widget build(BuildContext con) => new Padding(
      padding: new EdgeInsets.symmetric(horizontal: 20.0),
      child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        new Expanded(child: new Text(pair.item1)),
        new Align(child: new Text(pair.item2))
      ]));
}

class NoteWidget extends StatelessWidget {
  final String note;
  NoteWidget(this.note);

  Widget build(BuildContext con) => new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Text(note));
}

class NotesWidget extends StatelessWidget {
  final List<String> notes;
  NotesWidget(this.notes);

  Widget build(BuildContext con) => new Padding(
      padding: const EdgeInsets.all(12.0),
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Notes:",
                style: const TextStyle(fontWeight: FontWeight.bold))
          ]..addAll(notes.map((n) => new NoteWidget(n)))));
}

class PlayerDetailWidget extends StatefulWidget {
  final Player player;

  PlayerDetailWidget(this.player);
  State<StatefulWidget> createState() => new PlayerDetailWidgetState();
}

class PlayerDetailWidgetState extends State<PlayerDetailWidget> {
  PlayerCache pcache = new PlayerCache();
  List<String> notes = [];

  initState() {
    super.initState();
    widget.player.isWatched().whenComplete(() => setState(() {}));
    if (!widget.player.populated)
      widget.player.populateAsync(pcache).whenComplete(() => setState(() {}));
    refreshNotes();
  }

  void refreshNotes() async {
    final n = await pcache.getPlayerNotes(widget.player);
    setState(() {
      notes = n;
    });
  }

  Widget build(BuildContext con) => new Align(
      child: new Scaffold(
          appBar: new AppBar(title: new Text(widget.player.name), actions: [
            new IconButton(
                icon: new Icon(Icons.note_add),
                onPressed: tapNav(
                    (BuildContext con) => new PlayerNoteEntry(widget.player),
                    con,
                    refreshNotes)),
            new IconButton(
                icon: new Icon(widget.player.watchlist == null
                    ? Icons.cloud_off
                    : widget.player.watchlist ? Icons.star : Icons.star_border),
                onPressed: () {
                  pcache
                      .init()
                      .whenComplete(() => pcache.toggleWatchlist(widget.player))
                      .whenComplete(() => setState(() => null));
                })
          ]),
          body: new SingleChildScrollView(
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Center(
                        child: new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: widget.player.photoUrl == null
                                ? new CircularProgressIndicator()
                                : new GestureDetector(
                                    onTap: () {
                                      launch(
                                          'https://perfectgame.org/Players/Playerprofile.aspx?id=${widget.player.pgid}');
                                    },
                                    child: new Image.network(
                                        widget.player.photoUrl))))
                  ]
                    ..addAll(
                        widget.player.detailMap().map((p) => new KVText(p)))
                    ..add(new NotesWidget(notes))))));
}
