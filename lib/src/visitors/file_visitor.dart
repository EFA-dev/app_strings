import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:app_strings/src/models/field_tree.dart';
import 'package:app_strings/src/utils/reserved.dart';

// region [p]

class FileVisitor extends GeneralizingAstVisitor<void> {
  FileVisitor({
    required this.root,
    required this.rootPath, // @EFALang(path: "income")
    this.exclude,
    this.addValueField = true,
  });

  final FieldTree root;
  final String rootPath;
  final bool addValueField;
  final String? exclude;

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    // Sadece static alanları tara
    if (!node.isStatic) return;

    for (var field in node.fields.variables) {
      final initializer = field.initializer;
      if (initializer is! RecordLiteral) continue;

      final fieldName = field.name.lexeme.replaceAll("_", "");

      // Her static const field bir kök düğüm oluşturur
      // Path: "income.title"
      var keyNode = FieldNode(
        name: fieldName,
        path: rootPath.isEmpty ? fieldName : "$rootPath.$fieldName",
      );

      // Record içeriğini recursive olarak işle
      _buildRecord(keyNode, initializer);

      root.fields.add(keyNode);
    }

    super.visitFieldDeclaration(node);
  }

  void _buildRecord(FieldNode parent, RecordLiteral record) {
    // Record içindeki NamedExpression'ları (add: ..., en_US: ...) al
    final namedExpressions = record.fields.whereType<NamedExpression>();

    for (var namedExpr in namedExpressions) {
      final fieldName = namedExpr.name.label.name;
      final expression = namedExpr.expression;

      // 1. Reserved words kontrolü (Metadataları dışlamak için)
      if (addValueField == false && reservedWords.contains(fieldName)) continue;

      if (expression is RecordLiteral) {
        // Eğer bir Record ise alt daldır (Branch)
        var subNode = FieldNode(
          name: fieldName,
          path: "${parent.path}.$fieldName",
          parent: parent,
        );

        _buildRecord(subNode, expression);
        parent.children.add(subNode);
      } else if (expression is SimpleStringLiteral) {
        // 2. Exclude ve addValueField kontrolleri (Yaprak düğüm için)
        if (addValueField == false || fieldName == exclude) continue;

        // Eğer bir String ise çeviri değeridir (en_US, tr_TR)
        var valueNode = FieldNode(
          name: fieldName,
          value: expression.value,
          path: parent.path, // Mantıksal yolu parent ile aynı
          parent: parent,
          valueNode: true,
        );

        parent.children.add(valueNode);
        root.addValueField(path: parent.path, fieldNode: valueNode);
      }
    }
  }
}

// endregion
