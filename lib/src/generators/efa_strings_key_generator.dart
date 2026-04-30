import 'package:app_strings/src/models/field_tree.dart';
import 'package:app_strings/src/utils/formatter.dart';
import 'package:code_builder/code_builder.dart';

// region [p]

/// Generates a class with flat fields or nested records for string keys.
class EFAStringsKeyGenerator {
  EFAStringsKeyGenerator({required this.fieldTree, this.className = "AppStrings"});

  final FieldTree fieldTree;
  final String className;

  /// Builds the final formatted library string.
  String build() {
    var library = Library(
      (library) => library
        ..body.addAll(
          [
            refer("// region [p] \n\n"),
            Class(
              (c) => c
                ..name = className
                ..fields.addAll(_buildUnpackedFields()), // Unpacks the root to class fields
            ),
            refer("\n// endregion")
          ],
        ),
    );

    return Formatter.format(library);
  }

  /// Processes the field tree by skipping the root node and converting
  /// its direct children into static class fields.
  List<Field> _buildUnpackedFields() {
    ///* Identify the nodes to process.
    ///* If the tree has a root (e.g., 'income'), we take its children to keep the class flat.
    final rootNodes = fieldTree.fields;

    final List<FieldNode> nodesToProcess =
        rootNodes.isNotEmpty && rootNodes.first.children.isNotEmpty ? rootNodes.first.children : rootNodes;

    return nodesToProcess.map((field) {
      return Field(
        (f) {
          f
            ..modifier = FieldModifier.constant
            ..static = true
            ..name = field.name;

          if (field.children.isEmpty) {
            ///* Assign as a direct String if it's a leaf node
            f.assignment = literalString(field.path).code;
          } else {
            ///* Assign as a Record if it has nested children
            f.assignment = literalRecord([], _buildSubField(field.children)).code;
          }
        },
      );
    }).toList();
  }

  /// Recursively builds the Record structure for nested keys.
  Map<String, dynamic> _buildSubField(List<FieldNode> children) {
    var map = <String, dynamic>{};

    var entries = children.map((field) {
      if (field.children.isEmpty) {
        return MapEntry(field.name, field.path);
      } else {
        ///* Recursively call for deeper levels
        return MapEntry(field.name, literalRecord([], _buildSubField(field.children)));
      }
    });

    map.addEntries(entries);
    return map;
  }
}

// endregion
