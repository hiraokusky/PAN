import 'body.dart';
import 'memorygraph.dart';

class ThinkModule {
  MemoryFrame frameMemory = new MemoryFrame();

  MemoryFrame abstructMemory = new MemoryFrame();
  MemoryFrame relationMemory = new MemoryFrame();
  // 状態遷移の定義
  // メモリグラフ
  MemoryGraph memory = new MemoryGraph();
  MemoryGraph intentMemory = new MemoryGraph();
  MemoryGraph contextMemory = new MemoryGraph();
  MemoryGraph presentMemory = new MemoryGraph();

  // 連想中のノード
  List<MemoryNode> current = new List<MemoryNode>();

  // ノード名, 出現カウント
  Map<String, int> works = new Map<String, int>();

  ThinkModule() {
    // 能動的欲求
    memory.addNodeLink("#空腹", "", ">食べたい");
    memory.addNodeLink(">食べたい", "", "おなかすいた。なんか食べる");
    memory.addNodeLink(">食べたい", "", "!食事");

    memory.addNodeLink("#眠気", "", ">寝たい");
    memory.addNodeLink(">寝たい", "", "!睡眠");

    memory.addNodeLink("#喉乾く", "", ">飲みたい");
    memory.addNodeLink(">飲みたい", "", "のどがかわいた");
    memory.addNodeLink(">飲みたい", "", "!飲料");

    memory.addNodeLink("#排泄", "", ">トイレ");
    memory.addNodeLink(">トイレ", "", "トイレ");
    memory.addNodeLink(">トイレ", "", "!排泄");

    memory.addNodeLink("#排尿", "", ">おしっこ");
    memory.addNodeLink(">おしっこ", "", "おしっこ");
    memory.addNodeLink(">おしっこ", "", "!排尿");

    // 隣接ペア
    pairPattern.putIfAbsent("間繋ぎ", () => "");
    pairPattern.putIfAbsent("相槌", () => "");
    pairPattern.putIfAbsent("挨拶", () => "挨拶返し");
    pairPattern.putIfAbsent("共感求め", () => "同意");
    pairPattern.putIfAbsent("質問", () => "回答");
    pairPattern.putIfAbsent("呼掛け", () => "応答");

    var pairs = new List<String>();
    pairs.add("えー");
    pairs.add("えーと");
    pairDict.putIfAbsent("間繋ぎ", () => pairs);

    pairs = new List<String>();
    pairs.add("ふむふむ");
    pairDict.putIfAbsent("相槌", () => pairs);

    pairs = new List<String>();
    pairs.add("おはよう");
    pairs.add("こんにちは");
    pairDict.putIfAbsent("挨拶", () => pairs);

    pairs = new List<String>();
    pairs.add("/repeat");
    pairDict.putIfAbsent("挨拶返し", () => pairs);

    pairs = new List<String>();
    pairs.add("いい天気だね");
    pairDict.putIfAbsent("共感求め", () => pairs);

    pairs = new List<String>();
    pairs.add("そうだねー");
    pairs.add("天気なんてわからないけれど");
    pairDict.putIfAbsent("同意", () => pairs);

    pairs = new List<String>();
    pairs.add("調子はどう？");
    pairDict.putIfAbsent("質問", () => pairs);

    pairs = new List<String>();
    pairs.add("/answer");
    pairDict.putIfAbsent("回答", () => pairs);

    pairs = new List<String>();
    pairs.add("ねえ");
    pairDict.putIfAbsent("呼掛け", () => pairs);

    pairs = new List<String>();
    pairs.add("なあに");
    pairs.add("なに？");
    pairDict.putIfAbsent("応答", () => pairs);

    pairs = new List<String>();
    pairs.add("おなかすいたなー");
    pairDict.putIfAbsent(">食べたい", () => pairs);
    pairs = new List<String>();
    pairs.add("ねむい");
    pairDict.putIfAbsent(">寝たい", () => pairs);
    pairs = new List<String>();
    pairs.add("水くれ");
    pairDict.putIfAbsent(">飲みたい", () => pairs);
    pairs = new List<String>();
    pairs.add("ちょっといってくる");
    pairDict.putIfAbsent(">トイレ", () => pairs);
    pairs = new List<String>();
    pairs.add("ちょっといってくる");
    pairDict.putIfAbsent(">おしっこ", () => pairs);

    // 発言を生成する
    var say = "";

    // 名前知識
    // 名前 -> 関係性 -> 名前
    // 名前の関係性の定義
    // 名前化によって、文字列上での演算ができるようになる
    MemoryGraph frame;
    frame = frameMemory.getFrame("gen");

    // 一般化の表現
    frame.addNodeLink("山の手公園", "isa", "公園");

    // パターン化の表現（パターンの最初のノードを指定）
    frame.addNodeLink("roll", "->", "歩く");

    // 状態遷移の表現
    frame.addNodeLink("歩く", "#roll", "石がある");
    frame.addNodeLink("石がある", "#roll", "つまずく");

    // 構造化の表現
    frame.addNodeLink("滑り台", "on", "公園");
    frame.addNodeLink("滑り台", "color", "赤");

    // 4gamer
    frame = frameMemory.getFrame("4gamer");
    frame.addNodeLink("title1", "isa", "記事");
    frame.addNodeLink("title2", "isa", "記事");

    // 3DS版「ルイージマンション」の公式サイトがオープン。
    // 2人でオバケ退治に挑む協力プレイや，倒したオバケと再戦できる新モードの情報も
    frame = frameMemory.getFrame("4gamer.title2");
    frame.addNodeLink("ルイージマンション", "is", "3DS版");
    frame.addNodeLink("公式サイト", "of", "ルイージマンション");
    frame.addNodeLink("オープンした", "O", "公式サイト");
    frame.addNodeLink("オバケ退治", "by", "2人");
    frame.addNodeLink("挑む", "O", "オバケ退治");
    frame.addNodeLink("協力プレイ", "O", "挑む");
    frame.addNodeLink("オバケ", "is", "倒した");
    frame.addNodeLink("再戦できる", "O", "オバケ");
    frame.addNodeLink("新モード", "O", "再戦できる");
    frame.addNodeLink("情報", "O", "新モード");

    // 「星のドラゴンクエスト」のサービス3周年を記念するムービーが公開に。
    // 3000ジェムをプレゼントするキャンペーンも開催中
    var state = frameMemory.getState("4gamer.title1");
    state.addNodeLink("公開する", "そして", "開催中");

    var substate = state.getState("公開する");
    substate.addNodeLink("星のドラゴンクエスト", "の", "サービス");
    substate.addNodeLink("サービス", "は", "3周年");
    substate.addNodeLink("3周年", "を", "記念する");
    substate.addNodeLink("記念する", "の", "ムービー");
    substate.addNodeLink("ムービー", "を", "公開する");
    substate = state.getState("開催中");
    substate.addNodeLink("3000", "の", "ジェム");
    substate.addNodeLink("ジェム", "を", "プレゼントする");
    substate.addNodeLink("プレゼントする", "の", "キャンペーン");
    substate.addNodeLink("キャンペーン", "を", "開催中");

    // プレイヤーは祖父の宇宙葬をするため，大型客船で目的地へと向かっていたところ，
    // 大きな事故に巻き込まれてしまう。
    // なんとか一命をとりとめるも宇宙船は大破してしまい，
    // 宇宙空間に放り出された乗客の死体や積荷がそこかしこを漂っているという，
    // なんとも絶望的な状況だ。
    state = frameMemory.getState("Breathedgeの記事");
    state.addNodeLink("宇宙葬する", "ため", "向かう");
    state.addNodeLink("向かう", "とき", "巻き込まれる");
    state.addNodeLink("巻き込まれる", "しかし", "とりとめる");
    state.addNodeLink("とりとめる", "しかし", "大破する");
    state.addNodeLink("大破する", "そして", "漂う");
    state.addNodeLink("漂う", "な", "状況");

    substate = state.getState("宇宙葬する");
    substate.addNodeLink("プレイヤー", "は", "宇宙葬する");
    substate.addNodeLink("祖父", "の", "宇宙葬する");
    substate = state.getState("向かう");
    substate.addNodeLink("目的地", "へ", "向かっている");
    substate = state.getState("とりとめる");
    substate.addNodeLink("一命", "を", "とりとめる");
    substate = state.getState("大破する");
    substate.addNodeLink("宇宙船", "は", "大破する");
    substate = state.getState("漂う");
    substate.addNodeLink("宇宙空間", "に", "放り出す");
    substate.addNodeLink("放り出す", "される", "乗客");
    substate.addNodeLink("放り出す", "される", "積荷");
    substate.addNodeLink("乗客", "の", "死体");
    substate.addNodeLink("死体", "は", "漂う");
    substate.addNodeLink("積荷", "は", "漂う");
    substate.addNodeLink("そこかしこ", "に", "漂う");
    substate = state.getState("状況");
    substate.addNodeLink("絶望的", "な", "状況");
  }

  // 隣接ペアパターン
  Map<String, String> pairPattern = new Map<String, String>();

  // 隣接ペア記憶
  Map<String, List<String>> pairDict = new Map<String, List<String>>();

  // 現在の隣接ペア
  List<List<String>> pairs = new List<List<String>>();

  void pushPair(String pair, String msg) {
    pairs.add([pair, msg]);
  }

  List<String> popPair() {
    if (pairs.length > 0) {
      return pairs.removeLast();
    } else {
      return ["", ""];
    }
  }

  Map<String, List<String>> words;
  Map<String, List<String>> pwords;
  List<List<String>> patterns;

  void loadWords(
      Map<String, List<String>> dict, Map<String, List<String>> pdict, List<List<String>> ptns) {
    words = dict;
    pwords = pdict;
    patterns = ptns;
  }

  // 入力された文字列を構造化する
  void remember(String msg) {
    // 入力された文字列を辞書を使ってリスト化する
    List<String> what = new List<String>();
    List<String> where = new List<String>();
    matchWord(what, where, "プレイヤーは祖父の宇宙葬をするため，大型客船で目的地へと向かっていたところ，");
    matchWord(what, where, "大きな事故に巻き込まれてしまう。");
    matchWord(what, where, "なんとか一命をとりとめるも宇宙船は大破してしまい，");
    matchWord(what, where, "宇宙空間に放り出された乗客の死体や積荷がそこかしこを漂っているという，");
    matchWord(what, where, "なんとも絶望的な状況だ。");

    // 入力されたリストがどのフレームに属しているか調べる
    // 属しているフレームにセットする
    var state = frameMemory.getState("Breathedgeの記事");
    state.addList(what);

    // debug
    out = "";
    what.forEach((s) {
      out += s + " ";
    });
    where.forEach((s) {
      out += s + " ";
    });
  }

  // まず単語リストにする
  // リスト化した構造を抽象化するときに様々な組み合わせを試す
  List<String> matchWord(List<String> res, List<String> where, String text) {
    int mode = 0;
    for (var i = 0; i < text.length; i++) {
      var c = text[i];
      if (isSkip(c)) {
        continue;
      }

      switch (mode) {
        case 0: // 単語
          if (words[c] != null) {
            int len = 0;
            String match = "";
            words[c].forEach((p) {
              // 全単語をチェック
              if (text.startsWith(p, i)) {
                if (p.length > len) {
                  // マッチするもののうち、最も長いものを選択
                  len = p.length;
                  match = p;
                }
              }
            });
            if (match != "") {
              res.add(match);
              i += len - 1;
            }
          }
          mode = 1;
          break;
        case 1: // エッジ
          if (pwords[c] != null) {
            int len = 0;
            String match = "";
            pwords[c].forEach((p) {
              // 全単語をチェック
              if (text.startsWith(p, i)) {
                if (p.length > len) {
                  // マッチするもののうち、最も長いものを選択
                  len = p.length;
                  match = p;
                }
              }
            });
            if (match != "") {
              where.add(match);
              i += len - 1;
            }
          }
          mode = 0;
          break;
      }
    }
  }

  bool isSkip(String c) {
    switch (c) {
      case ",":
      case ".":
      case " ":
      case "　":
      case "，":
      case "．":
      case "、":
      case "。":
      case "\t":
      case "\r":
      case "\n":
        return true;
    }
    return false;
  }

  // 入力を受けて記憶する
  String out;

  // 記憶の中で一致する構造を全部リスト化する
  void input(String msg) {
    out = "";
    frameMemory.states.forEach((key, frame) {
      var list = frame.getLinkNodesByName(msg);
      list.forEach((node) {
        out += node[0] + "" + node[1] + "" + node[2] + "\n";
      });
      list = frame.getRevLinkNodesByName(msg);
      list.forEach((node) {
        out += node[0] + "" + node[1] + "" + node[2] + "\n";
      });

      frame.states.forEach((key, frame) {
        var list = frame.getLinkNodesByName(msg);
        list.forEach((node) {
          out += node[0] + "" + node[1] + "" + node[2] + "\n";
        });
        list = frame.getRevLinkNodesByName(msg);
        list.forEach((node) {
          out += node[0] + "" + node[1] + "" + node[2] + "\n";
        });
      });
    });
  }

  // 考える処理
  String update(int dt) {
    return out;

    // 生理現象を更新
    var res = updateBody(dt);
    if (res != null) {
      return res;
    }

    // 隣接ペアを処理
    var pair = popPair();
    if (pair[0] != "") {
      var list = pairDict[pair[0]];
      return list[0];
    }

    // 見つけたノード名をカウントする
    if (current.length > 0) {
      current.forEach((p) {
        if (works.containsKey(p.name)) {
          works[p.name] += 1;
        } else {
          works[p.name] = 1;
        }
      });
    } else {
      // カレントがなければ何か見つける
    }

    // 最初のworkを処理
    int max = 0;
    String key = "";
    if (works.length > 0) {
      works.forEach((k, n) {
        if (n > max) {
          max = n;
        }
        key += k;

        switch (k) {
          case "!食事":
            body.eat();
            break;
          case "!睡眠":
            body.sleep();
            break;
          case "!飲料":
            body.drink();
            break;
          case "!排泄":
            body.evacuate();
            break;
          case "!排尿":
            body.urinate();
            break;
        }

        if (pairDict.containsKey(k)) {
          var list = pairDict[k];
          key = list[0];
          return;
        }
      });
    }
    if (max > 0) {
      return key;
    } else {
      return "";
    }
  }

  BodyModule body = new BodyModule();

  // 次に進める
  String updateBody(int dt) {
    // 1時間経過
    body.update(dt);

    if (body.mode == Mode.Wake) {
      if (body.sleepy >= 0.8) {
        current.add(memory.getNode("#眠気"));
      }
      if (body.calorie <= 0.5) {
        current.add(memory.getNode("#空腹"));
      }
      if (body.water <= 0.9) {
        current.add(memory.getNode("#喉乾く"));
      }
      if (body.excretion >= 0.8) {
        current.add(memory.getNode("#排泄"));
      }
      if (body.urination >= 0.8) {
        current.add(memory.getNode("#排尿"));
      }
      return null;
    } else {
      if (body.mode == Mode.Sleep) {
        return "zzz";
      }
      if (body.mode == Mode.Faint) {
        return "...";
      } else {
        return "...";
      }
    }
  }
}
