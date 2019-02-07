import 'dart:async';
import 'dart:math' as math;

import 'fire.dart';

class SimpleJsonRepository {
  SimpleFirestoreRepository repos;
  Map<String, dynamic> store = new Map<String, dynamic>();

  SimpleJsonRepository(String db) {
    repos = new SimpleFirestoreRepository(db);

    // ファイルからロードする
    
  }

  String getId(SimpleSession session, String id) {
    return session.family.id + "." + id;
  }

  void create(SimpleSession session, Map<String, dynamic> data) {
    repos.create(data);
  }
  
  void overwriteById(SimpleSession session, String id, Map<String, dynamic> data) {
    repos.overwriteById(getId(session, id), data);
  }
  
  void updateById(SimpleSession session, String id, Map<String, dynamic> data) {
    repos.updateById(getId(session, id), data);
  }
}

/// アカウント管理のためのマネージャー
/// 以下のデータはすべてファミリー別の同一コレクションにいれる
/// これによってそれぞれのネストを可能にする

/// ファミリー
class SimpleFamily {
  /// family型
  String type;

  /// UUID
  String id;

  /// 可読性のある変更のできないユニークなID
  String key;

  /// 子グループ/ユーザーID
  List<String> groupIds;

  SimpleFamily(){
    id = "";
  }
}

/// グループ
class SimpleGroup {
  /// group型
  String type;

  /// UUID
  String id;

  /// 可読性のある変更のできないユニークなID
  String key;

  /// 属するファミリーID
  String fid;

  /// 子グループ/ユーザーID
  List<String> userIds;
}

/// ユーザー
class SimpleUser {
  /// user型
  String type;

  /// UUID
  String id;

  /// 可読性のある変更のできないユニークなID
  String key;

  /// 属するファミリーID
  String fid;

  /// 属するグループID
  List<String> groupIds;

  SimpleUser() {
    id = "";
  }
}

/// セッション
///
/// キャッシュも含めて情報を保持する
/// そうすることで、オフラインでも使えるようにする
class SimpleSession {
  String id;
  SimpleFamily family;  
  SimpleUser user;

  SimpleSession() {
    id = "";
    family = new SimpleFamily();
    user = new SimpleUser();
  }
}
