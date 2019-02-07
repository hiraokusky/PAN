import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

@override
class Memo extends StatelessWidget {
  String title;
  String body;
  Memo(this.title, this.body);

  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: _botRow(context),
    );
  }

  Widget _botRow(BuildContext context) {
    return new Row(
      //mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Flexible(
            child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text("", style: Theme.of(context).textTheme.subhead),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(
                body,
              ),
            ),
          ],
        )),
      ],
    );
  }
}
