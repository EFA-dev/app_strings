import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:app_strings/app_strings.dart';
import 'package:app_strings/src/generators/app_strings_key_generator.dart';
import 'package:app_strings/src/models/field_tree.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

// region [p]
class AppStringsKeyBuilder extends GeneratorForAnnotation<AppStringsConfig> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    ///* Build the FieldTree from the source file
    var sourceTree = await FieldTree.fromAst(buildStep, includeValues: false);
    if (sourceTree == null) {
      return null;
    }

    ///* Get the key class name
    final keyClassName = annotation.read("keyClassName").stringValue;

    ///* Generate the key file
    var keyBuilder = AppStringsKeyGenerator(
      fieldTree: sourceTree,
      className: keyClassName,
    );
    var fileContent = keyBuilder.build();

    ///* Write the generated key file
    var newPath = p.withoutExtension(buildStep.inputId.path).replaceAll(".importer", "");
    var filePath = p.setExtension(newPath, ".key.dart");
    var sourceFile = File(filePath);
    sourceFile.writeAsString(fileContent);
  }
}

// endregion
