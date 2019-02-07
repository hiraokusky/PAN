// 欲求の定義
class DesireModule {
  // 欲求はkvの文字列であらわす
  // 欲求prefixは$
  // 意図prefixは#
  // 感情prefixは!

  // 記憶グラフに欲求名ノードがある
  // 記憶グラフを処理して、欲求名ノードに到達したら、原因をaddする
  // 行動して、原因が解消されたらresolveする

  // 何かがあったときに、欲求名ノードが活性化する。それは記憶グラフによる

  // 欲求名, 原因名リスト
  Map<String, List<String>> desires = new Map<String, List<String>>();

  DesireModule() {
    // 能動的欲求
    desires.putIfAbsent(">傍にいたい", () => new List<String>());
    desires.putIfAbsent(">食べたい", () => new List<String>());
    desires.putIfAbsent(">知りたい", () => new List<String>());
    desires.putIfAbsent(">寝たい", () => new List<String>());
    desires.putIfAbsent(">話したい", () => new List<String>());

    // 受動的欲求
    desires.putIfAbsent("<なぐさめられたい", () => new List<String>());
    desires.putIfAbsent("<ほめられたい", () => new List<String>());
  }

  // 今自分が欲していることを知る
  String findDesire() {
    // 欲求の原因が一番多いものを選択
    int max = 0;
    String desire = "";
    desires.forEach((k, v) {
      if (v.length > max) {
        desire = k;
        max = v.length;
      }
    });
    return desire;
  }

  // 欲求が生まれる
  void addDesire(String desire, String reason) {
    var reasons = desires[desire];
    if (!reasons.contains(reason)) {
      reasons.add(reason);
    }
  }

  // 欲求の原因が解消する
  void resolveDesire(String desire, String reason) {
    var reasons = desires[desire];
    if (reasons.contains(reason)) {
      reasons.remove(reason);
    }
  }
}
