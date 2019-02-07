import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_pedometer/flutter_pedometer.dart';
import 'package:pimp_my_button/pimp_my_button.dart';

import 'chat/scenario.dart';
import 'note/main.dart';

import 'simple/particle.dart';
import 'simple/family.dart';

import 'note/memo.dart';
import 'simple/db.dart';

import 'chat/message.dart';
import 'chat/body.dart';
import 'chat/memory.dart';
import 'chat/feature.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Remindfullnessor',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

// メインクラス
class ChatScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  String _stepCountValue = 'Unknown';
  StreamSubscription<int> _subscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    openDB();

    FeatureModule f = new FeatureModule();
    f.test();
  }

  TodoDb db;

  Future openDB() async {
    List notes;
    db = new TodoDb();

    // await db.saveNote((new Note("Flutter Tutorials2", "Create SQLite Tutorial")).toMap());
    // await db.saveNote(
    //     (new Note("Android Development2", "Build Firebase Android Apps")).toMap());
    // await db
    //     .saveNote((new Note("Mobile App R&D2", "Research more cross-flatforms")).toMap());

    print('=== getAllNotes() ===');
    notes = await db.getAllNotes();
    notes.forEach((note) => print(note));

    int count = await db.getCount();
    print('Count: $count');

    loadTodo();

    // print('=== getNote(2) ===');
    // Note note = await db.getNote(2);
    // print(note.toMap());

    // print('=== updateNote[id:1] ===');
    // Note updatedNote = Note.fromMap(
    //     {'id': 1, 'title': 'Flutter Tuts', 'description': 'Create SQLite Tut'});
    // await db.updateNote(updatedNote);

    // notes = await db.getAllNotes();
    // notes.forEach((note) => print(note));

    // print('=== deleteNote(2) ===');
    // await db.deleteNote(2);
    // notes = await db.getAllNotes();
    // notes.forEach((note) => print(note));
  }

  Future closeDB() async {
    await db.close();
  }

  // 歩数を取得してみる
  Future<void> initPlatformState() async {
    FlutterPedometer pedometer = new FlutterPedometer();
    _subscription = pedometer.stepCountStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onData(int stepCountValue) async {
    setState(() {
      _stepCountValue = "$stepCountValue";
    });
  }

  void _onDone() {}
  void _onError(error) {
    print("Flutter Pedometer Error: $error");
  }

  int mainMode = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(
          tooltip: 'menu button',
          icon: const Icon(
            Icons.backspace,
            color: Colors.white,
          ),
          //onPressed: () => _scaffoldKey.currentState.openDrawer()
        ),
        actions: <Widget>[
          // メイトのメッセージ
          new Container(
            padding: const EdgeInsets.fromLTRB(1.0, 1.0, 10.0, 1.0),
            alignment: Alignment.centerRight,
            child: chara = new Chara(Text(getMessage()), think),
          ),
          // メイトの画像
          new Container(
            margin: const EdgeInsets.only(right: 8.0),
            width: 32.0,
            height: 32.0,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.asset('images/face.png')),
          )
        ],
        backgroundColor: Color.fromARGB(255, 66, 103, 178),
      ),

      // メイン
      body: (mainMode == 0)
          ? _buildTodoLine()
          : (mainMode == 1) ? _buildDoneLine() : _buildChatLine(),

      // 追加ボタン
      floatingActionButton: (mainMode == 2)
          ? null
          : new PimpedButton(
              particle: FireworkParticle(),
              //particle: DemoParticle(),
              pimpedWidgetBuilder: (context, controller) {
                return FloatingActionButton(
                  child: new Icon(Icons.add),
                  onPressed: () {
                    controller.forward(from: 0.0);
                    StatelessWidget dialog;
                    dialog = _buildAddDialog();

                    showDialog(
                        context: context,
                        builder: (context) {
                          return dialog;
                        });
                  },
                );
              },
            ),

      // 画面切り替え
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: mainMode,
        onTap: (int index) {
          setState(() {
            this.mainMode = index;
          });
          //_navigateToScreens(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.assignment),
            title: new Text('TODO'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.assignment_turned_in),
            title: new Text('DONE'),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text('MATE'))
        ],
      ),
    );
  }

  final List<Memo> _todos = <Memo>[];
  final List<Memo> _dones = <Memo>[];

  Widget _buildTodoLine() {
    return new Column(children: <Widget>[
      // チャットライン
      new Flexible(
          child: new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, int index) => new GestureDetector(
            child: _todos[index], onTap: () => _tapTodo(index)),
        itemCount: _todos.length,
      )),
    ]);
  }

  Widget _buildDoneLine() {
    return new Column(children: <Widget>[
      // チャットライン
      new Flexible(
          child: new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, int index) => new GestureDetector(
            child: _dones[index], onTap: () => _tapDone(index)),
        itemCount: _dones.length,
      )),
    ]);
  }

  void _tapTodo(int index) {
    StatelessWidget dialog;
    dialog = _buildFBDialog(index);

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  void _tapDone(int index) {}

  Memo _memo = new Memo('', '');

  // TODOを入力するダイアログ
  Widget _buildAddDialog() {
    return SimpleDialog(title: Text("TODO"), children: <Widget>[
      new TextField(
          maxLines: 2,
          decoration: new InputDecoration(hintText: "なにする？"),
          controller: new TextEditingController(text: _memo.body),
          onChanged: (String newBody) {
            _memo.body = newBody;
          }),
      Center(
          child: new Container(
              margin: const EdgeInsets.all(10.0),
              height: 40.0,
              width: 150.0,
              child: new FlatButton(
                  child: new Text('登録'),
                  color: Colors.lightBlue,
                  textColor: Colors.white,
                  onPressed: () {
                    _updateTodo();
                  }))),
    ]);
  }

  /// DBからTODOをロードする
  Future loadTodo() async {
    var all = await db.getAll();
    setState(() {
      all.forEach((p) {
        var _memo = new Memo(p['title'], p['body']);
        _todos.add(_memo);
      });
    });
  }

  /// DBにTODOをセーブする
  Future saveTodo(Memo memo) async {
    var note = new Map<String, dynamic>();
    note.putIfAbsent('title', () => memo.title);
    note.putIfAbsent('body', () => memo.body);
    db.saveNote(note);
  }

  Future removeTodo(Memo memo) async {
    db.deleteByTitle(memo.title);
  }

  void _updateTodo() {
    var text = _memo.body;
    setState(() {
      _isComposing = false;
    });
    setState(() {
      saveTodo(_memo);
      _todos.add(_memo);
      _memo = new Memo('', '');
    });
    Navigator.pop(context);
    _updateTalk("me", text + 'やる');
  }

  // FBを入力するダイアログ
  Widget _buildFBDialog(int index) {
    return SimpleDialog(
        title: Text("おわり！ " + index.toString()),
        children: <Widget>[
          new IconButton(
            icon: const Icon(Icons.sentiment_dissatisfied),
            onPressed: () => _fbTodo(index, -1),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
          new IconButton(
            icon: const Icon(Icons.sentiment_neutral),
            onPressed: () => _fbTodo(index, 0),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
          new IconButton(
            icon: const Icon(Icons.sentiment_satisfied),
            onPressed: () => _fbTodo(index, 1),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
        ]);
  }

  /// TODOをDONEにする
  void _fbTodo(int index, int fb) {
    var todo = _todos[index];
    setState(() {
      _isComposing = false;
    });
    setState(() {
      removeTodo(todo);
      _todos.removeAt(index);
      _dones.add(todo);
    });
    Navigator.pop(context);
    _updateTalk("me", todo.body + 'おわり ' + fb.toString());
  }

  /// TODOを削除する
  void _removeTodo(int index, int fb) {
    var todo = _todos[index];
    setState(() {
      _isComposing = false;
    });
    setState(() {
      removeTodo(todo);
      _todos.removeAt(index);
      _dones.add(todo);
    });
    Navigator.pop(context);
  }

  final List<ChatMessage> _messages = <ChatMessage>[];

  Widget _buildChatLine() {
    return new Column(children: <Widget>[
      // チャットライン
      new Flexible(
          child: new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, int index) => _messages[index],
        itemCount: _messages.length,
      )),
      // // スタンプライン
      // new Divider(height: 1.0),
      // new Container(
      //   decoration: new BoxDecoration(color: Theme.of(context).cardColor),
      //   child: (mode == 0) ? _buildRecomLine() : _buildStampLine(),
      // ),
      // インプットライン
      new Divider(height: 1.0),
      new Container(
        decoration: new BoxDecoration(color: Theme.of(context).cardColor),
        child: _buildTextComposer(),
      ),
    ]);
  }

  // リコメスタンプ
  //
  // 現在の状態を把握して、コンテキストマップからパターンにマッチする行動をリストアップ
  // 優先度順に表示する
  Widget _buildRecomLine() {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => iconButtonPressed("戻る"),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
          new IconButton(
            icon: const Icon(Icons.sentiment_satisfied),
            onPressed: () => iconButtonPressed("外出"),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
        ]);
  }

  String getMessage() {
    return "$_stepCountValue" + "歩も歩いたの？！";
  }

  // にこにこスタンプ
  //
  // 実施したらリコメを押す。次ににこにこマークが出てくる。
  // にこにこマークを押して、いまの気分を入力。
  Widget _buildStampLine() {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => iconButtonPressed("戻る"),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
          new IconButton(
            icon: const Icon(Icons.sentiment_satisfied),
            onPressed: () => iconButtonPressed("外出"),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
          new IconButton(
            icon: const Icon(Icons.sentiment_neutral),
            onPressed: () => iconButtonPressed("ねえ"),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
          new IconButton(
            icon: const Icon(Icons.sentiment_dissatisfied),
            onPressed: () => iconButtonPressed("飲み会"),
            iconSize: 48.0,
            color: const Color(0xFF000000),
          ),
        ]);
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration: new InputDecoration.collapsed(hintText: "いまどんな感じ？"),
              ),
            ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton(
                        child: new Text("Send"),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : () => _handleNext(),
                      )
                    : new IconButton(
                        icon: new Icon(Icons.send),
                        onPressed: _isComposing
                            ? () => _handleSubmitted(_textController.text)
                            : () => _handleNext(),
                      )),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border:
                      new Border(top: new BorderSide(color: Colors.grey[200])))
              : null),
    );
  }

  Chara chara;
  SimpleSession session = new SimpleSession();
  Scenario scenario = new Scenario();
  int mode = 0;
  ThinkModule think = new ThinkModule();

  void iconButtonPressed(String text) {
    _updateTalk("me", text);
    mode = 1 - mode;
  }

  // プレイヤーの発言
  void _handleSubmitted(String text) {
    _textController.clear();
    _updateTalk("me", text);

    if (text == "e") {
      think.body.eat();
    } else if (text == "d") {
      think.body.drink();
    } else if (text == "ex") {
      think.body.evacuate();
    } else if (text == "dx") {
      think.body.urinate();
    } else {
        //think.input(text);
        think.remember("");
      var res = think.update(1);
      if (res != null && res.length > 0) {
        _updateTalk("bot", res);
      }
      // 発言を単語に分解する
      // var s = scenario.say(session, chara, text);
      // _updateTalk("bot", s);
    }
  }

  // 次に進める
  void _handleNext() {
    // 1時間経過
    var res = think.update(1800 * 1000);

    String s = think.body.mode.toString();
    s += "\ns " + think.body.sleepy.toString();
    s += "\nc " + think.body.calorie.toString();
    s += "\nw " + think.body.water.toString();
    s += "\nco " + think.body.excretion.toString();
    s += "\nwo " + think.body.urination.toString();

    _updateTalk("bot", s);
    _updateTalk("bot", res);
  }

  void _updateTalk(String userType, String text) {
    setState(() {
      _isComposing = false;
    });
    ChatMessage message = new ChatMessage(
      text: text,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 200),
        vsync: this,
      ),
      userType: userType,
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }
}
