import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

/// JSONリポジトリ
///
/// @todo SimpleSessionを使ってファミリーごとにデータを格納できるようにする
/// ファミリーごとユーザーグループごとにコレクション名を分ける
class SimpleFirestoreRepository {
  String collectionName;

  SimpleFirestoreRepository(String db) {
    collectionName = db;
  }

  CollectionReference getTable() {
    return Firestore.instance.collection(collectionName);
  }

  Map<String, Map<String, dynamic>> caches =
      new Map<String, Map<String, dynamic>>();

  /// 常に新しいデータを保存する
  ///
  /// IDはUUIDになる
  void create(Map<String, dynamic> data) {
    DocumentReference docRef = getTable().document();
    docRef.setData(data).then((data) {}).catchError((e) {});
  }

  void write(String id, Map<String, dynamic> data) {
    DocumentReference docRef = getTable().document(id);
    docRef.setData(data).catchError((e) {});
    caches.putIfAbsent(id, () => data);
  }

  Map<String, dynamic> read(String id){
    return caches[id];
  }

  /// 同じIDのデータを上書きする
  ///
  /// 元のデータは消える
  void overwriteById(String id, Map<String, dynamic> data) {
    write(id, data);
  }

  /// 同じIDのデータを更新する
  ///
  /// dataにあるキーのデータは上書きする
  /// ただしキーのデータがリストの場合、最後尾に追加する
  /// ただし同じ値の場合、追加しない
  void updateById(String id, Map<String, dynamic> data) {
    DocumentReference docRef = getTable().document(id);
    docRef.get().then((doc) {
      if (doc.data == null) {
        write(id, data);
      } else {
        data.forEach((key, val) {
          if (doc.data[key] is List) {
            var list = new List();
            (doc.data[key] as List).forEach((item) {
              list.add(item);
            });
            if (val is List) {
              val.forEach((v) {
                if (!list.contains(v)) {
                  list.add(v);
                }
              });
            } else {
              if (!list.contains(val)) {
                list.add(val);
              }
            }
            val = list;
          }
          doc.data[key] = val;
        });
        write(id, doc.data);
      }
    }).catchError((e) {});
  }

  Future<Map<String, dynamic>> getData(String id) async {
    CollectionReference colRef = Firestore.instance.collection(collectionName);
    DocumentReference docRef = colRef.document(id);
    DocumentSnapshot result = await docRef.get();
    return result.data;
  }
}
