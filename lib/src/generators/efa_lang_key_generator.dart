import 'package:app_strings/src/models/field_tree.dart';
import 'package:app_strings/src/utils/formatter.dart';
import 'package:code_builder/code_builder.dart';

// region [p]

/// Generates a class with EFAKey objects instead of raw Strings.
class EFALangKeyGenerator {
  EFALangKeyGenerator({required this.fieldTree, required this.className}) : loaderClassName = "${className}Loader";

  final FieldTree fieldTree;
  final String className;
  final String loaderClassName;

  /// Builds the final formatted library string.
  String build() {
    var library = Library(
      (library) => library
        ..directives.add(Directive.import('package:efa_core/efa_core.dart'))
        ..body.addAll(
          [
            refer("// region [p] \n\n"),
            Class(
              (c) => c
                ..name = className
                ..fields.addAll([
                  // 1. Static reference to the local loader
                  Field((f) => f
                    ..name = 'loader'
                    ..static = true
                    ..modifier = FieldModifier.constant
                    ..assignment = refer('$loaderClassName()').code),

                  // 2. Unpacked EFAKey fields
                  ..._buildUnpackedFields(),
                ]),
            ),
            refer("\n// endregion")
          ],
        ),
    );

    return Formatter.format(library);
  }

  /// Skip the root node and convert children into EFAKey fields or Records.
  List<Field> _buildUnpackedFields() {
    final rootNodes = fieldTree.fields;

    final List<FieldNode> nodesToProcess =
        rootNodes.isNotEmpty && rootNodes.first.children.isNotEmpty ? rootNodes.first.children : rootNodes;

    return nodesToProcess.map((field) {
      return Field(
        (f) => f
          ..modifier = FieldModifier.constant
          ..static = true
          ..name = field.name
          ..assignment = _generateAssignment(field).code,
      );
    }).toList();
  }

  /// Recursive helper to create EFAKey or Record of EFAKeys
  Expression _generateAssignment(FieldNode field) {
    if (field.children.isEmpty) {
      // Leaf Node: Construct EFAKey(path, loader)
      return refer('EFAKey').call([
        literalString(field.path),
        refer('loader'),
      ]);
    } else {
      // Branch Node: Create a Record of nested EFAKeys
      final Map<String, Expression> recordFields = {
        for (var child in field.children) child.name: _generateAssignment(child)
      };

      return literalRecord([], recordFields);
    }
  }
}

// endregion
