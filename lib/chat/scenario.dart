import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'memory.dart';
import '../simple/family.dart';

// ノードで名前を管理する
// 名前の種類は、ノード間のエッジで表現する
// 名前はエッジ、つまり、どういう関係があるかで意味が変わる

/// ノード
class RemindNode {
  // ノード名
  String name;
  // エッジ名リスト
  List<String> edges = new List<String>();

  RemindNode({this.name});
}

/// エッジ
class RemindEdge {
  // ノード名.エッジタイプ
  String nodetag;
  // 次ノード名リスト
  List<String> nodes = new List<String>();

  RemindEdge({this.nodetag});
}

// グラフ
class RemindState {
  /// ノードとエッジのストレージ
  Map<String, RemindNode> nodes = new Map<String, RemindNode>();
  Map<String, RemindEdge> edges = new Map<String, RemindEdge>();

  /// ノードだけをつくる
  void addNode(String name) {
    nodes.putIfAbsent(name, () => new RemindNode());
  }

  /// ノードをつくってリンクする
  void addNodeLink(String parent, String tag, String name) {
    var node = nodes.putIfAbsent(parent, () => new RemindNode(name: parent));
    var newnode = nodes.putIfAbsent(name, () => new RemindNode(name: name));
    var nodetag = parent + "." + tag;
    var edge =
        edges.putIfAbsent(nodetag, () => new RemindEdge(nodetag: nodetag));
    node.edges.add(tag);
    edge.nodes.add(newnode.name);
  }

  RemindNode getNode(String name) {
    if (nodes.containsKey(name)) {
      return nodes[name];
    } else {
      return null;
    }
  }

  /// リンクされているノードをリストで返す
  List<RemindNode> getLinkNodes(String name, String tag) {
    var nodetag = name + "." + tag;
    var list = edges[nodetag].nodes;
    var res = new List<RemindNode>();
    list.forEach((s) {
      res.add(nodes[s]);
    });
    return res;
  }
}

class Scenario {
  SimpleJsonRepository wordRepos = new SimpleJsonRepository('words');
  SimpleJsonRepository chatRepos = new SimpleJsonRepository('chats');

  List<String> currentScene = null;
  int currentSceneIndex = 0;

  // 意図
  List<List<String>> intentStack = new List<List<String>>();

  // 私の意図
  String intent = "";

  // 知りたいこと
  String what = "";
  // 教えてもらったこと
  String content = "";

  Scenario() {
    remember();
  }

  // チャットを保存する
  void saveChat(SimpleSession session, String who, String what) {
    chatRepos.overwriteById(session, DateTime.now().toIso8601String(),
        {'when': DateTime.now(), 'who': who, 'what': what});
  }

  // 単語の意味を保存する
  void saveWord(SimpleSession session, String word, String what) {
    wordRepos.updateById(session, word, {
      'word': word,
      'whats': [what]
    });
  }

  // リマインドしたいことをグラフで保持する
  RemindState nowRemind = new RemindState();

  // リマインドすることを記憶する
  String remember() {
    // 日時と場所と行動を記憶する

    nowRemind.addNodeLink("外出", "確認", "家の鍵持った？");
    nowRemind.addNodeLink("外出", "確認", "戸締りした？");
  }

  // リマインド
  String remind(SimpleSession session, Chara chara) {
    // 日時と場所を確認する
  }

  // 発言
  String say(SimpleSession session, Chara chara, String text) {
    var intent = processIntent();

    // 特に発言がなかったら呼びかけモード
    if (text == "") {
      if (intent == "呼びかけ") {
        return "ねえ";
      } else {
        // 処理する意図がなければ、自発的な発言に入る
        // まずはリマインドをチェック
      }

      var s = next(session, chara);
      return s;
    }

    // とりあえずあなたが言ったことは全部記録しておく
    saveChat(session, 'me', text);

    // 発言をリストに分解する
    var w = _analyzeWord(chara, text);

    var res = "";
    res = "フムフム、";
    w.forEach((p) {
      res += p;
    });
    res += "、と。";

    // リストから意味を知る

    // 意味から意図を知る

    // 行動なら行動リストに記録する

    if (w.contains("外出")) {
      // あなたが外出する場合
      if (nowRemind.getNode("外出") != null) {
        // あなたは外出する。わたしは何をしよう？
        // あなたが忘れ物をするのが心配だ。確認しよう。
        // 天気を心配している。確認しよう。
        // 交通事情を心配している。確認しよう。

        // 確認しておくこと
        var list = nowRemind.getLinkNodes("外出", "確認");

        //
        // あなたが確認できてないことは何か？
        // 直近のコンテキストと過去の忘れた事実から求める

        list.forEach((p) {
          res += p.name;
        });
        return res;
      }
    }
    return res;

    // 全然わからなかったら
    if (w.length == 0) {}

    if (!intent.startsWith("-")) {
      // 意図と異なる発言だったら、発言の意味を知って、意図を組み替える
    }

    // 質問モード
    res = teachme(session, chara, text);
    if (res != null) {
      return res;
    }

    // 理解モード
    return understand(session, chara, text);
  }

  // 自分が意図していることを最初から処理する
  String processIntent() {
    // もしスタックが空なら何かつくる
    if (intentStack.length == 0) {
      List<String> intents = new List<String>();
      intents.add("呼びかけ");
      intents.add("-応答");
      intentStack.add(intents);
    }

    List<String> latest = intentStack[intentStack.length - 1];
    var intent = latest[0];
    latest.removeAt(0);
    if (latest.length == 0) {
      intentStack.remove(latest);
    }
    return intent;
  }

  // 知らない単語を教えてもらう
  String unknown(SimpleSession session, Chara chara, String text) {
    // 知らない言葉を教えてもらいたい
    // スタックする意図を現在のコンテキストから決める
    // 意図をスタックする
    List<String> intents = new List<String>();
    intents.add("呼びかけ");
    intents.add("質問");
    intents.add("-回答");
    intentStack.add(intents);

    // 教えてモードに移行
    var intent = processIntent();
    if (intent == "呼びかけ") {
      what = text + "";
      var res = "えーと、あのー";
      return res;
    } else {
      var res = "…";
      return res;
    }
  }

  String understand(SimpleSession session, Chara chara, String text) {
    // 発言を単語に分解する
    var w = _analyzeWord(chara, text);
    if (w.length == 0) {
      // 知っている単語がない
      return unknown(session, chara, text);
    } else {
      // 知っている単語があった
      // 知っている文法に当てはめる
      // 全部あてはまったら、この理解であっているか確認

      // 違っていたら、
      // 教えてモードに移行

      // 知っている単語だったのでシナリオからロード
      var s = "";
      w.forEach((p) {
        s += p + " ";
      });
      //_updateTalk("bot", s);

      // シナリオからロード
      // 単語列と最もマッチするシーンをロード
      Map<String, int> count = new Map<String, int>();
      w.forEach((p) {
        chara.scenes.forEach((s, l) {
          if (s.contains(p)) {
            if (!count.containsKey(s)) {
              count[s] = 0;
            }
            count[s] = count[s] + 1;
          }
        });
      });
      // 単語と最も多くマッチした文を選択
      if (count.length > 0) {
        int max = 0;
        var currentSceneName = "";
        count.forEach((s, n) {
          if (max < n) {
            currentSceneName = s;
          }
        });

        currentScene = chara.scenes[currentSceneName];
        currentSceneIndex = 0;
        return currentScene[currentSceneIndex];
      } else {
        return "？";
      }
    }
  }

  // 教えてモード
  String teachme(SimpleSession session, Chara chara, String text) {
    if (intent == "あなた:教える>私") {
      // あなたが言ったことが意味になる

      // 言ったことが意味なのか、文法なのかを理解(指示で教えるのか動作で教えるのか)
      if (text.contains(":") || text.contains(">") || text.contains(".")) {
        // 文法
        // whatを指示された文法で解析する
        // 指示には単語も同時に指定されるので単語を登録する
        // 単語＋文字のリストと文法のセットを登録する
      } else {
        // 意味
        content = text;
      }

      // あなたの言ったことを反復して確認する
      intent = chara.intentMap[intent];
      String res = intent + "\n";
      res += what + "は" + content + "なんだ？";
      return res;
    }

    if (intent == "私:確認>あなた") {
      // 何か言ったら違うということ
      intent += "|あなた:否定>私";
      // 否定されたら、また教えてもらう
      intent = chara.intentMap[intent];
      String res = intent + "\n";
      res += "違う？じゃあ何？\n";
      return res;
    }

    return null;
  }

  String next(SimpleSession session, Chara chara) {
    if (intent == "私:確認>あなた") {
      // 何も言わなかったそうだということ
      intent += "|あなた:肯定>私";
      // 肯定されたら、よろこぶ
      intent = chara.intentMap[intent];
      String res = intent + "\n";
      res += "わかった！\n";
      chara.addWord(what);
      saveWord(session, what, content);
      return res;
    }

    // 発言しなかったら意図を消す
    intent = "";

    // 意図が合っててうれしいなら連想する
    // あるいはこれを言われたらあなたは何を感じるかたずねる

    currentSceneIndex++;
    if (currentScene != null && currentSceneIndex < currentScene.length) {
      return currentScene[currentSceneIndex];
    } else {
      return "……";
    }
  }

  // 記憶している単語とそうでない文字のリストに分解する
  List<String> _analyzeWord(Chara chara, String text) {
    var w = new List<String>();
    for (var i = 0; i < text.length; i++) {
      var c = text[i];
      if (chara.words[c] != null) {
        int len = 0;
        String match = "";
        chara.words[c].forEach((p) {
          // 全単語をチェック
          if (text.startsWith(p, i)) {
            if (p.length > len) {
              // マッチするもののうち、最も長いものを選択
              len = p.length;
              match = p;
            }
          }
        });
        if (len > 0) {
          // マッチしたら、類義語チェック
          var syno = chara.synos[match];
          if (syno != null) {
            match = syno;
          }

          w.add(match);
          i += match.length - 1;
        } else {
          // 先頭文字はあったが辞書にない
          w.add("-" + c);
        }
      } else {
        // 辞書にない
        w.add("-" + c);
      }
    }
    return w;
  }
}

// キャラ
class Chara extends StatelessWidget {
  // 意図マップ
  Map<String, String> intentMap = new Map<String, String>();

  // 類義語定義
  Map<String, String> synos = new Map<String, String>();

  // シーンごとのシナリオ定義
  Map<String, List<String>> scenes = new Map<String, List<String>>();

  // 会話リスト
  List<String> talks = new List<String>();

  Text column;
  ThinkModule think;

  Chara(Text column, ThinkModule think) {
    this.column = column;
    this.think = think;
  }

  // コマンド定義
  Map<String, List<String>> words = new Map<String, List<String>>();

  // コマンド定義
  Map<String, List<String>> pwords = new Map<String, List<String>>();

  // コマンド定義
  List<List<String>> patterns = new List<List<String>>();

  void addWord(String s) {
    // 単語を先頭文字ごとにリストに入れる
    var w = words[s[0]];
    if (w == null) {
      w = new List<String>();
    }
    if (!w.contains(s)) {
      w.add(s);
    }
    words[s[0]] = w;
  }

  void addPatternWord(String s) {
    // 単語を先頭文字ごとにリストに入れる
    var w = pwords[s[0]];
    if (w == null) {
      w = new List<String>();
    }
    if (!w.contains(s)) {
      w.add(s);
    }
    pwords[s[0]] = w;
  }

  // キャラのシナリオをロードする
  Future<String> loadTalks() async {
    // コマンドとなる単語リストをロードする
    var str = await rootBundle.loadString('assets/words.txt');
    // var str = await rootBundle        .loadString('assets/jawiki-20180901-all-titles-in-ns0.txt');
    var strs = str.split('\r');
    strs.forEach((ss) {
      var sss = ss.split('\n');
      sss.forEach((s) {
        if (s != null && s.length > 0) {
          // 単語を先頭文字ごとにリストに入れる
          addWord(s);
        }
      });
      // // 類義語チェック
      // strss.forEach((s) {
      //   if (s != null && s.length > 0) {
      //     if (s == strss[0]) {
      //       // 先頭単語は結果
      //     } else {
      //       // 類義語と先頭単語を関連付ける
      //       synos[s] = strss[0];
      //     }
      //   }
      // });
    });

    // パターンを登録する
    str = await rootBundle.loadString('assets/words1.txt');
    strs = str.split('\r');
    strs.forEach((ss) {
      var sss = ss.split('\n');
      sss.forEach((s4) {
        // パターンの構成要素を登録する
        var s5 = s4.split(' ');
        s5.forEach((s) {
          if (s != null && s.length > 0 && s != "O") {
            // 単語を先頭文字ごとにリストに入れる
            addPatternWord(s);
          }
        });
        if (s5.length > 0) {
          patterns.add(s5);
        }
      });
    });

    // 辞書を設定する
    think.loadWords(words, pwords, null);

    // // シナリオをロードする
    // var s = await rootBundle.loadString('assets/s001.txt');
    // var ss = s.split('\r\n');

    // String sceneName = "";
    // ss.forEach((s) {
    //   if (s != null && s.length > 0) {
    //     if (s[0] == "#") {
    //       // タグ:コマンド列に分解
    //       var w = scenes[s];
    //       if (w == null) {
    //         scenes[s] = new List<String>();
    //       }
    //       sceneName = s;
    //     } else if (sceneName.length > 0) {
    //       // シーンに文を追加する
    //       scenes[sceneName].add(s);
    //     }
    //   } else {
    //     // 空行
    //     sceneName = "";
    //   }
    // });

    // s.splitMapJoin((new RegExp("「.*」")), onMatch: (m) {
    //   // 「」でくくられた部分だけを抜き出してリストに入れる
    //   var s = m.group(0);
    //   s = s.substring(1, s.length - 1);
    //   talks.add(s);
    // });

    return "";
  }

  // ロード中のインジケータ＋ロード後の処理
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: loadTalks(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          String str = snapshot.data;
        }
        return snapshot.hasData ? column : new CircularProgressIndicator();

        ///load until snapshot.hasData resolves to true
      },
    );
  }
}
