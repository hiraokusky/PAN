/// 抽象化のための木を管理するモジュール
class FeatureModule {
  // 2つの文字列を持つリスト
  // クラス構造
  // 下位→上位のクラス構造 #parent 上位クラス名
  List<List<String>> parents = new List<List<String>>();
  List<List<String>> details = new List<List<String>>();

  // B hasa D
  // 特徴変数を定義する

  // B hasnta E
  // 否定変数を定義する

  // JSONリスト（キャッシュのため名前キーを持つ）
  // 特徴構造
  // 下位→上位の条件化構造 #cond 下位クラス名
  Map<String, Map<String, dynamic>> features =
      new Map<String, Map<String, dynamic>>();

  void test() {
    // parentは上位クラス
    setParent("人間", "動物");
    setParent("動物", "生物");
    setParent("犬", "動物");
    setParent("猫", "動物");

    // detailは条件付きクラス、もしくは言い換え（言い換えには暗黙的に条件がつくことが多い）
    setDetail("人間", "子供");
    setDetail("人間", "大人");
    setDetail("人間", "人");

    print('is ' + isa("人間", "動物").toString());
    print('is ' + isa("人間", "子供").toString());
    print('of1 ' + isof("人間", "動物").toString());
    print('of ' + isof("人間", "子供").toString());
    print('of ' + isof("子供", "人間").toString());
    print('of ' + isof("人", "人間").toString());
    print('of ' + getClasses("子供")[0]);
  }

  // 同じ特徴を持っているものは同じクラスになる
  // 違う特徴を持っているものは別のクラスになる
  // この処理はいつでも行われ、自分が納得するまで繰り返される
  // つまり、正解がない処理である
  // 確率的にこうであるとしても、新しい情報を受けて変わることがある
  // これはフレームを分割する機能がある
  void update() {}

  // A isa B
  // 上位クラスBを定義する
  void setParent(String a, String b) {
    var match = false;
    parents.forEach((p) {
      if (p[0] == a && p[1] == b) {
        match = true;
      }
    });
    if (!match) {
      var p = new List<String>();
      p.add(a);
      p.add(b);
      parents.add(p);
    }
  }

  // A isa bか判定する
  bool isa(String a, String b) {
    var match = false;
    parents.forEach((p) {
      if (p[0] == a && p[1] == b) {
        match = true;
        return;
      }
    });
    return match;
  }

  // Aの上位クラスを全部取得する
  List<String> getParents(String a) {
    List<String> list = new List<String>();
    parents.forEach((p) {
      if (p[0] == a) {
        list.add(p[1]);
      }
    });
    return list;
  }

  // B of A
  // 条件付けクラスBを定義する
  void setDetail(String a, String b) {
    var match = false;
    details.forEach((p) {
      if (p[0] == a && p[1] == b) {
        match = true;
      }
    });
    if (!match) {
      var p = new List<String>();
      p.add(a);
      p.add(b);
      details.add(p);
    }
  }

  void setDetails(String a, List<String> b) {
    b.forEach((p) {
      setDetail(a, p);
    });
  }

  // B of Aか判定する
  bool isof(String b, String a) {
    var match = false;
    details.forEach((p) {
      if (p[0] == a && p[1] == b) {
        match = true;
        return;
      }
    });
    return match;
  }

  // Aの条件付きクラスを全部取得する
  List<String> getDetails(String a) {
    List<String> list = new List<String>();
    details.forEach((p) {
      if (p[0] == a) {
        list.add(p[1]);
      }
    });
    return list;
  }

  // Bのクラスを取得する
  // クラスを取得しないとparentはとれない
  List<String> getClasses(String b) {
    List<String> list = new List<String>();
    details.forEach((p) {
      if (p[0] == b || p[1] == b) {
        if (!list.contains(p[0])) {
          list.add(p[0]);
        }
      }
    });
    return list;
  }

  //

  Map<String, dynamic> getFeatures(String s) {
    if (!features.containsKey(s)) {
      features.putIfAbsent(s, () => new Map<String, dynamic>());
    }
    return features[s];
  }

  // A hasa C
  // 特徴を付加する
  void setFeature(String a, String c, bool valid) {
    var f = getFeatures(a);
    f.putIfAbsent(c, () => valid);
  }
}
