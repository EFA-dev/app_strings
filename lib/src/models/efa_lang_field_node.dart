import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:app_strings/src/visitors/efa_lang_file_visitor.dart';

// region [p]

///* Represents a single node in the localization hiyerarşisi.
class EFALangFieldNode {
  EFALangFieldNode(this.name, {this.parent});

  final String name;
  final EFALangFieldNode? parent;
  final Map<String, EFALangFieldNode> children = {};
  final Map<String, String> translations = {};

  ///* Generates the dot-separated unique key path (e.g., income.actions.edit).
  String get path => (parent == null || parent!.name == 'root') ? name : '${parent!.path}.$name';

  ///* Checks if the node is a leaf containing translation values.
  bool get isLeaf => translations.isNotEmpty;
}

///* Manages the collection and merging of localization trees.
class EFALangTree {
  EFALangTree({EFALangFieldNode? root}) : root = root ?? EFALangFieldNode('root');

  final EFALangFieldNode root;

  ///* Scans a class declaration to populate the tree.
  void scan(ClassDeclaration node) {
    node.accept(EFALangVisitor(root));
  }

  ///* Merges another tree into this one (e.g., combining JSON data with Code data).
  void combine(EFALangTree? other) {
    if (other == null) return;
    _merge(root, other.root);
  }

  void _merge(EFALangFieldNode target, EFALangFieldNode source) {
    target.translations.addAll(source.translations);
    source.children.forEach((name, sourceChild) {
      final targetChild = target.children.putIfAbsent(name, () => EFALangFieldNode(name, parent: target));
      _merge(targetChild, sourceChild);
    });
  }

  ///* Loads and parses translation data from a JSON file.
  static Future<EFALangTree?> fromJson(String path, String locale) async {
    final file = File(path);
    if (!file.existsSync()) return null;

    final content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    final tree = EFALangTree();
    _fillFromMap(tree.root, data, locale);
    return tree;
  }

  static void _fillFromMap(EFALangFieldNode parent, Map<String, dynamic> data, String locale) {
    data.forEach((key, value) {
      final node = parent.children.putIfAbsent(key, () => EFALangFieldNode(key, parent: parent));
      if (value is Map<String, dynamic>) {
        _fillFromMap(node, value, locale);
      } else if (value is String) {
        node.translations[locale] = value;
      }
    });
  }
}

// endregion
