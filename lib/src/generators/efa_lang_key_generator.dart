import 'package:app_strings/src/models/field_tree.dart';
import 'package:app_strings/src/utils/formatter.dart';
import 'package:code_builder/code_builder.dart';

// region [p]

/// Generates EFALang compatible keys and records using FieldTree structure
class EFALangKeyGenerator {
  EFALangKeyGenerator({
    required this.fieldTree,
    this.className = "AppStrings",
  });

  final FieldTree fieldTree;
  final String className;

  String build() {
    final library = Library(
      (l) => l
        ..ignoreForFile.addAll(['unused_field', 'unused_element', 'non_constant_identifier_names'])
        ..body.addAll([
          refer("import 'package:efa_core/efa_core.dart';\n"),
          Class(
            (c) => c
              ..name = className
              ..fields.addAll(_buildTopLevelFields()),
          ),
        ]),
    );

    return Formatter.format(library);
  }

  /// Builds the top-level fields of the class
  List<Field> _buildTopLevelFields() {
    return fieldTree.fields.map((field) {
      // Bir node'un çocuklarının hepsi valueNode ise, bu bir yaprak düğümdür (Leaf).
      final isLeaf = field.children.every((child) => child.valueNode);

      return Field((f) => f
        ..static = true
        ..modifier = FieldModifier.final$
        ..name = field.name
        ..assignment = isLeaf ? _createEfaKeyExpression(field).code : _buildRecordExpression(field.children).code);
    }).toList();
  }

  /// Recursively builds Record structures or EFAKey instances
  Expression _buildRecordExpression(List<FieldNode> children) {
    final Map<String, Expression> recordFields = {};

    // Sadece value olmayan (alt dal olan) çocukları işliyoruz
    final structuralChildren = children.where((c) => !c.valueNode).toList();

    for (var child in structuralChildren) {
      final isLeaf = child.children.every((c) => c.valueNode);

      if (isLeaf) {
        recordFields[child.name] = _createEfaKeyExpression(child);
      } else {
        recordFields[child.name] = _buildRecordExpression(child.children);
      }
    }

    return literalRecord([], recordFields);
  }

  /// Creates an EFAKey expression by extracting values from children
  Expression _createEfaKeyExpression(FieldNode node) {
    // valueNode olan çocukları bulup bir map oluşturuyoruz (en_US: "Hello", tr_TR: "Merhaba")
    final Map<String, String> languageData = {
      for (var child in node.children.where((c) => c.valueNode)) child.name: child.value ?? ""
    };

    return refer('EFAKey').newInstance([], {
      'path': literalString(node.path),
      'data': Method((m) => m
        ..lambda = true
        ..body = literalMap(languageData).code).closure,
    });
  }
}

// endregion
