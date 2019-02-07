
class MemoryFrame {
  Map<String, MemoryGraph> frames = new Map<String, MemoryGraph>();

  MemoryGraph getFrame(String frameName){
    return frames.putIfAbsent(frameName, ()=>new MemoryGraph());
  }
  
  Map<String, MemoryState> states = new Map<String, MemoryState>();

  MemoryState getState(String stateName){
    return states.putIfAbsent(stateName, ()=>new MemoryState());
  }
}

class MemoryState {
  Map<String, MemoryState> states = new Map<String, MemoryState>();

  MemoryState getState(String stateName){
    return states.putIfAbsent(stateName, ()=>new MemoryState());
  }

  List<List<String>> list = new List<List<String>>();
  
  void addList(List<String> data) {
    list.add(data);
  }

  void addNodeLink(String nodeName, String tagName, String nextNodeName) {
    list.add([nodeName, tagName, nextNodeName]);
  }

  List<List<String>> getLinkNodesByName(String nodeName) {
    List<List<String>> res = new List<List<String>>();
    list.forEach((s){
      if (s[0] == nodeName) {
        res.add(s);
      }
    });
    return res;
  }

  List<List<String>> getRevLinkNodesByName(String nodeName) {
    List<List<String>> res = new List<List<String>>();
    list.forEach((s){
      if (s[2] == nodeName) {
        res.add(s);
      }
    });
    return res;
  }
}

// グラフ
class MemoryGraph {
  /// ノードとエッジのストレージ
  Map<String, MemoryNode> nodes = new Map<String, MemoryNode>();

  /// ノードだけをつくる
  void addNode(String nodeName) {
    nodes.putIfAbsent(nodeName, () => new MemoryNode(name: nodeName));
  }

  /// ノードをつくってリンクする
  void addNodeLink(String nodeName, String tagName, String nextNodeName) {
    var node = nodes.putIfAbsent(
        nodeName, () => new MemoryNode(name: nodeName));
    var newnode = nodes.putIfAbsent(
        nextNodeName, () => new MemoryNode(name: nextNodeName));
    node.edges.add(new MemoryEdge(tag: tagName, next:nextNodeName));
    newnode.parents.add(nodeName);
  }

  /// ノードをつくってリンクする
  void addLink(MemoryNode nodeName, String tagName, String nextNodeName) {
    addNodeLink(nodeName.name, tagName, nextNodeName);
  }

  /// ノード名のノードを得る
  MemoryNode getNode(String nodeName) {
    if (nodes.containsKey(nodeName)) {
      return nodes[nodeName];
    } else {
      return null;
    }
  }

  /// 特定のタグにリンクされているノードをリストで返す
  List<MemoryNode> getLinkNodes(MemoryNode nodeName) {
    return getLinkNodesByName(nodeName.name);
  }

  /// 特定のタグにリンクされているノードをリストで返す
  List<MemoryNode> getLinkNodesByName(String nodeName) {
    var res = new List<MemoryNode>();
    var node = getNode(nodeName);
    if (node != null) {
      node.edges.forEach((edge){
        res.add(getNode(edge.next));
      });
    }
    return res;
  }

  List<MemoryNode> getRevLinkNodesByName(String nodeName) {
    var res = new List<MemoryNode>();
    var node = getNode(nodeName);
    if (node != null) {
      node.parents.forEach((parent){
        res.add(getNode(parent));
      });
    }
    return res;
  }
}

/// ノード
class MemoryNode {
  // ノード名
  String name;

  // エッジ名リスト
  List<MemoryEdge> edges = new List<MemoryEdge>();

  // 被リンクノードリスト
  List<String> parents = new List<String>();

  MemoryNode({this.name});
}

/// エッジ
class MemoryEdge {
  // ノード名.エッジタイプ
  // i:意図状態遷移ネットワーク(リスト)
  // s:構造ネットワーク(関数)
  // c:抽象化ネットワーク(置き換え)
  // g:文法ネットワーク(JSON)
  // h:発言ネットワーク(文字リスト)
  String tag;

  // 次ノード名リスト
  String next;

  MemoryEdge({this.tag, this.next});
}
