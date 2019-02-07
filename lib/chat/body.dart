// 生理的現象を管理する
class BodyModule {
  // 眠気
  // 1時間ごとに0.05増える, 16時間たつと0.8になる
  // 0.8を超えると眠くなる
  // 寝ると1時間ごとに0.1減る
  double sleepy = 0.0;

  // カロリー
  // 食べるとカロリーが増える
  // 1になると満腹
  // 0.5になると空腹
  // 1食事で0.5回復
  double calorie = 1.0;

  // 水分
  // 食べると水分が増える
  // 1になると満腹
  // 0.5になると渇き
  // 1食事で0.1回復
  // 1飲みで0.1回復
  double water = 1.0;

  // 排泄
  // カロリーが水分があると、時間がたつごとに排泄に移動する
  // 睡眠中以外で移動する
  // 水分は5時間で0.5へり, 2ふえる(つまり1飲みで2回排尿)
  // カロリーは5時間で0.5へり, 0.5ふえる(つまり2食事で1回排泄)
  // トイレにいくと0になる
  double excretion = 0.0; // カロリー
  double urination = 0.0; // 水分

  // 1時間あたりms
  double hourms = 3600000.0;

  // モード
  Mode mode = Mode.Wake;

  // 生理情報を更新する
  // dtはms
  // 1時間は3600x100ms
  void update(int dt) {
    // 1時間1となるpt
    double pt = (dt.toDouble() / hourms);

    // 眠気更新
    if (mode == Mode.Wake) {
      sleepy += pt * 0.05;

      // カロリー更新
      calorie -= pt * 0.1;
      excretion += pt * 0.1;

      // 水分更新
      water -= pt * 0.1;
      urination += pt * 0.2;
    } else {
      sleepy -= pt * 0.1;
    }

    // 強制行動
    if (mode != Mode.Sleep) {
      if (sleepy >= 1.0) {
        mode = Mode.Sleep;
      }
    } else {
      if (sleepy <= 0.0) {
        mode = Mode.Wake;
      }
    }
    if (mode != Mode.Faint) {
      if (calorie <= 0.0 || water <= 0.0) {
        mode = Mode.Faint;
      }
    } else {
      if (calorie > 0.0 && water > 0.0) {
        mode = Mode.Wake;
      }
    }

    // クランプ
    sleepy = clamp(sleepy);
    calorie = clamp(calorie);
    excretion = clamp(excretion);
    water = clamp(water);
    urination = clamp(urination);
  }

  void sleep() {
    mode = Mode.Sleep;
  }

  void eat() {
    calorie += 0.5;
    water += 0.1;
  }

  void drink() {
    water += 0.1;
  }

  void evacuate() {
    excretion = 0.0;
  }

  void urinate() {
    urination = 0.0;
  }

  double clamp(double a) {
    if (a > 1.0) {
      a = 1.0;
    } else if (a < 0.0) {
      a = 0.0;
    }
    return a;
  }
}

enum Mode {
  // 覚醒中
  Wake,
  // 睡眠中
  Sleep,
  // 昏倒中
  Faint
}
