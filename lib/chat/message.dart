import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

@override
class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController, this.userType});
  final String text;
  final AnimationController animationController;
  final String userType;

  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: userType == "me" ? _userRow(context) : _botRow(context),
    );
  }

  Widget _userRow(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new Flexible(
            child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(
                text,
              ),
            ),
          ],
        )),
      ],
    );
  }

  Widget _botRow(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.only(right: 8.0),
          width: 32.0,
          height: 32.0,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Image.asset('images/face.png')),
        ),
        new Flexible(
            child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(
                text,
              ),
            ),
          ],
        )),
      ],
    );
  }
}
