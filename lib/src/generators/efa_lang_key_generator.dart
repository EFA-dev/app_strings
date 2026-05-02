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
          // Note: code_builder'ın refer metodu bazen importları karışık basabilir,
          // manuel eklemek daha temiz sonuç veriyor.
          Directive.import('package:efa_core/efa_core.dart'),
          Class(
            (c) => c
              ..name = className
              ..constructors.add(Constructor((con) => con..name = '_')) // Private constructor
              ..fields.addAll(_buildTopLevelFields()),
          ),
        ]),
    );

    return Formatter.format(library);
  }

  /// Builds the top-level fields of the class
  List<Field> _buildTopLevelFields() {
    return fieldTree.fields.map((field) {
      final isLeaf = field.children.every((child) => child.valueNode);

      return Field((f) {
        f
          ..static = true
          ..modifier = FieldModifier.final$
          ..name = field.name
          ..assignment = isLeaf ? _createRegisterExpression(field).code : _buildRecordExpression(field.children).code;

        // Eğer yaprak düğümse tipini String yapıyoruz (Path döndüğü için)
        if (isLeaf) f.type = refer('String');
      });
    }).toList();
  }

  /// Recursively builds Record structures or EFAKey instances
  Expression _buildRecordExpression(List<FieldNode> children) {
    final Map<String, Expression> recordFields = {};

    final structuralChildren = children.where((c) => !c.valueNode).toList();

    for (var child in structuralChildren) {
      final isLeaf = child.children.every((c) => c.valueNode);

      if (isLeaf) {
        recordFields[child.name] = _createRegisterExpression(child);
      } else {
        recordFields[child.name] = _buildRecordExpression(child.children);
      }
    }

    return literalRecord([], recordFields);
  }

  /// Creates an EFALocalizationManager.register expression
  Expression _createRegisterExpression(FieldNode node) {
    final Map<String, String> languageData = {
      for (var child in node.children.where((c) => c.valueNode)) child.name: child.value ?? ""
    };

    // EFALocalizationManager.register("path", (path) => EFAKey(...))
    return refer('EFALocalizationManager').newInstanceNamed('register', [
      literalString(node.path),
      Method((m) => m
        ..requiredParameters.add(Parameter((p) => p..name = 'path'))
        ..lambda = true
        ..body = refer('EFAKey').newInstance([], {
          'path': refer('path'), // Injected path
          'data': Method((dm) => dm
            ..lambda = true
            ..body = literalMap(languageData).code).closure,
        }).code).closure,
    ]);
  }
}

// endregion
