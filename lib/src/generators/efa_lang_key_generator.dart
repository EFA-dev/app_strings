import 'package:app_strings/src/models/efa_lang_field_node.dart';

///* Assuming Formatter is your custom utility
import 'package:app_strings/src/utils/formatter.dart';
import 'package:code_builder/code_builder.dart';

// region [p]

///* Generates paths for keys using the EFALangTree structure
class EFALangKeyGenerator {
  EFALangKeyGenerator({required this.tree, required this.className});

  final EFALangTree tree;
  final String className;

  ///* Builds the key class with EFALang standards
  String build() {
    ///* Automatically prefixing the class name for the keys
    final keyClassName = '_${className}Keys';

    var library = Library(
      (library) => library
        ..body.addAll(
          [
            refer("// region [p] \n\n"),
            Class(
              (c) => c
                ..name = keyClassName
                ..fields.addAll(_buildField()),
            ),
            refer("\n // [endregion]")
          ],
        ),
    );

    return Formatter.format(library);
  }

  ///* Builds Record type fields from the root children
  List<Field> _buildField() {
    return tree.root.children.values.map((node) {
      return Field(
        (p0) => p0
          ..modifier = FieldModifier.constant
          ..static = true
          ..name = node.name
          ..assignment = literalRecord([], _buildSubField(node.children.values.toList())).code,
      );
    }).toList();
  }

  ///* Builds fields children recursively
  Map<String, dynamic> _buildSubField(List<EFALangFieldNode> children) {
    var map = <String, dynamic>{};

    var processedEntries = children.map((node) {
      if (node.children.isEmpty) {
        ///* Leaf node: return the dot-separated path
        return MapEntry(node.name, node.path);
      } else {
        ///* Branch node: recurse further into the record
        return MapEntry(node.name, literalRecord([], _buildSubField(node.children.values.toList())));
      }
    });

    map.addEntries(processedEntries);
    return map;
  }
}

// endregion
