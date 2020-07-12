import 'package:flash_chat/components/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  MainScaffold({this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MainDrawer(),
      body: body,
    );
  }
}
