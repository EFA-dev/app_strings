import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:app_strings/src/models/efa_lang_field_node.dart';

// region [p]

///* Visitor that scans a class for the '_texts' record and builds an EFALangFieldNode tree.
class EFALangVisitor extends RecursiveAstVisitor<void> {
  EFALangVisitor(this.root);

  ///* The root node where the extracted fields will be attached.
  final EFALangFieldNode root;

  ///* Targets the specific field named '_texts'.
  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    ///* Only process static fields.
    if (!node.isStatic) return;

    for (var variable in node.fields.variables) {
      ///* Ensure we only parse the variable named '_texts'.
      if (variable.name.lexeme != '_texts') continue;

      final initializer = variable.initializer;

      ///* The initializer must be a RecordLiteral (e.g., _texts = (...)).
      if (initializer is RecordLiteral) {
        _parseRecord(root, initializer);
      }
    }
  }

  ///* Recursively parses RecordLiterals to distinguish between branches and translation leaves.
  void _parseRecord(EFALangFieldNode parent, RecordLiteral record) {
    for (final field in record.fields) {
      if (field is NamedExpression) {
        final fieldName = field.name.label.name;
        final expression = field.expression;

        if (expression is RecordLiteral) {
          ///* This is a branch (a nested category like 'actions' or 'errors').
          final branchNode = parent.children.putIfAbsent(fieldName, () => EFALangFieldNode(fieldName, parent: parent));
          _parseRecord(branchNode, expression);
        } else if (expression is SimpleStringLiteral) {
          ///* This is a leaf node (a translation value like en_US: 'Hello').
          ///* The key here (fieldName) is the locale code.
          parent.translations[fieldName] = expression.value;
        }
      }
    }
  }
}

// endregion
