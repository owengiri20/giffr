import 'package:flash_chat/components/main_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  static const String id = "home_screen";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
        body: Container(
      child: Text("hfghf"),
    ));
  }
}
