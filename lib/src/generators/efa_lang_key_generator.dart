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

  // Global plural/gender keys for detection
  final pluralKeys = {'zero_', 'one_', 'two_', 'few_', 'many_', 'other_'};
  final genderKeys = {'male_', 'female_', 'other_'};

  String build() {
    final library = Library(
      (l) => l
        ..ignoreForFile.addAll(['unused_field', 'unused_element', 'non_constant_identifier_names'])
        ..body.addAll([
          Directive.import('package:efa_core/efa_core.dart'),
          Class(
            (c) => c
              ..name = className
              ..constructors.add(Constructor((con) => con..name = '_'))
              ..fields.addAll(_buildTopLevelFields()),
          ),
        ]),
    );

    return Formatter.format(library);
  }

  /// Check if the node is an Atomic Key (Flat, Plural or Gender)
  bool _isAtomicKey(FieldNode node) {
    // 1. Durum: Çocukları doğrudan dil paketleri mi? (verifying)
    final isFlatLeaf = node.children.isNotEmpty && node.children.every((child) => child.valueNode);

    // 2. Durum: Çocuklarından biri 'other' mı? (xDay, user)
    // Bu durumda içeri girmeyi durdurup bu node'u paketlemeliyiz.
    final hasOther = node.children.any((child) => child.name == 'other_');

    return isFlatLeaf || hasOther;
  }

  List<Field> _buildTopLevelFields() {
    return fieldTree.fields.map((field) {
      final isAtomic = _isAtomicKey(field);

      return Field((f) {
        f
          ..static = true
          ..modifier = FieldModifier.final$
          ..name = field.name
          ..assignment = isAtomic ? _createRegisterExpression(field).code : _buildRecordExpression(field.children).code;

        // Atomic ise tip belirtmiyoruz (CodeBuilder register'ı otomatik çözer)
      });
    }).toList();
  }

  Expression _buildRecordExpression(List<FieldNode> children) {
    final Map<String, Expression> recordFields = {};

    // Sadece yapısal düğümleri gez (değer düğümlerini record içinde field olarak basma)
    final structuralChildren = children.where((c) => !c.valueNode).toList();

    for (var child in structuralChildren) {
      if (_isAtomicKey(child)) {
        recordFields[child.name] = _createRegisterExpression(child);
      } else {
        recordFields[child.name] = _buildRecordExpression(child.children);
      }
    }

    return literalRecord([], recordFields);
  }

  /// Creates an EFAKey.register(...) expression with proper data/plural/gender mapping
  Expression _createRegisterExpression(FieldNode node) {
    final Map<String, String> standardData = {};
    final Map<String, Map<String, String>> pluralMap = {};
    final Map<String, Map<String, String>> genderMap = {};

    final bool isVariation = node.children.any((c) => c.name == 'other_');

    if (isVariation) {
      // Scenario: Plural/Gender Package
      for (var variationNode in node.children) {
        final String keyName = variationNode.name;
        final Map<String, String> translations = {
          for (var lang in variationNode.children.where((c) => c.valueNode)) lang.name: lang.value ?? ""
        };

        if (translations.isNotEmpty) {
          if (keyName == 'other_') standardData.addAll(translations);

          if (pluralKeys.contains(keyName)) {
            for (var entry in translations.entries) {
              pluralMap.putIfAbsent(entry.key, () => {})[keyName] = entry.value;
            }
          } else if (genderKeys.contains(keyName)) {
            for (var entry in translations.entries) {
              genderMap.putIfAbsent(entry.key, () => {})[keyName] = entry.value;
            }
          }
        }
      }
    } else {
      // Scenario: Flat Translation
      standardData.addAll({for (var child in node.children.where((c) => c.valueNode)) child.name: child.value ?? ""});
    }

    final Map<String, Expression> namedArgs = {
      'path': literalString(node.path),
    };

    if (standardData.isNotEmpty) {
      namedArgs['data'] = Method((dm) => dm
        ..lambda = true
        ..body = literalMap(standardData).code).closure;
    }

    if (pluralMap.isNotEmpty) {
      namedArgs['pluralData'] = Method((dm) => dm
        ..lambda = true
        ..body = literalMap(pluralMap).code).closure;
    }

    if (genderMap.isNotEmpty) {
      namedArgs['genderData'] = Method((dm) => dm
        ..lambda = true
        ..body = literalMap(genderMap).code).closure;
    }

    return refer('EFAKey').newInstanceNamed('register', [], namedArgs);
  }
}
// endregion
