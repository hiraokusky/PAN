import 'package:flutter/material.dart';

import 'detail.dart';
import 'memo.dart';
import 'create.dart';

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Note App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Home(title: 'Note List'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  List<Memo> memos = new List<Memo>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: _list(),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'add note',
        child: new Icon(Icons.add),
        onPressed: () {
          Memo newMemo = new Memo('','');
          memos.add(newMemo);
          Navigator.push(context, new MaterialPageRoute<Null>(
              settings: const RouteSettings(name: "/create"),
              builder: (BuildContext context) => new Create(newMemo)
          ));
        }
      ),
    );
  }

  Widget _list() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: memos.length,
        itemBuilder: (context, i) {
          final item = memos[i];
          return new Dismissible(
            // Each Dismissible must contain a Key. Keys allow Flutter to
            // uniquely identify Widgets.
            key: new Key(item.title),
            // We also need to provide a function that will tell our app
            // what to do after an item has been swiped away.
            onDismissed: (direction) {
              memos.removeAt(i);

              Scaffold.of(context).showSnackBar(
                  new SnackBar(content: new Text("Memo dismissed")));
            },
            // Show a red background as the item is swiped away
            background: new Container(color: Colors.red),
            child: new ListTile(
              title: new Text(
                item.title,
                maxLines: 1,
                style: _biggerFont,
              ),
              onTap: () {
                Navigator.push(context, new MaterialPageRoute<Null>(
                    settings: const RouteSettings(name: "/detail"),
                    builder: (BuildContext context) => new Detail(item)
                ));
              },
            ),
          );
        },
    );
  }
}
