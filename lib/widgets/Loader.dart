import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class _Loader extends StatelessWidget {
  final RenderLoadCallback renderLoad;
  final InitStateCallback initState;
  final RenderSuccessCallback renderSuccess;

  _Loader(
      {@required this.renderLoad,
      @required this.initState,
      @required this.renderSuccess});

  Widget build(BuildContext con) => new AsyncLoader(
      initState: initState,
      renderLoad: renderLoad,
      renderSuccess: renderSuccess,
      renderError: ([error]) => const Text("ERROR"));
}

class LoaderScaffold extends StatelessWidget {
  final String title;
  final InitStateCallback initState;
  final RenderSuccessCallback renderSuccess;

  LoaderScaffold(
      {@required this.title,
      @required this.initState,
      @required this.renderSuccess});

  Widget build(BuildContext con) => new Scaffold(
      appBar: new AppBar(title: new Text(title)),
      body: new Loader(
        initState: initState,
        renderSuccess: renderSuccess,
      ));
}

class Loader extends StatelessWidget {
  final InitStateCallback initState;
  final RenderSuccessCallback renderSuccess;

  Loader({@required this.initState, @required this.renderSuccess});

  Widget build(BuildContext con) => new _Loader(
        initState: initState,
        renderLoad: () =>
            const Center(child: const CircularProgressIndicator()),
        renderSuccess: renderSuccess,
      );
}
