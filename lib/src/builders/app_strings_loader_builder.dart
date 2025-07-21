import 'dart:io';

import 'package:analyzer/dart/element/element2.dart';
import 'package:app_strings/app_strings.dart';
import 'package:app_strings/src/generators/app_strings_loader_generator.dart';
import 'package:app_strings/src/models/field_tree.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

// region [p]
class AppStringsLoaderBuilder extends GeneratorForAnnotation<AppStringsConfig> {
  @override
  generateForAnnotatedElement(Element2 element, ConstantReader annotation, BuildStep buildStep) async {
    ///* Check if the loaderExport annotation is true
    var generate = annotation.read("easyLoader").boolValue;
    if (!generate) {
      return null;
    }

    ///* Build the FieldTree from the source file
    var sourceTree = await FieldTree.fromAst(buildStep);
    if (sourceTree == null) {
      return null;
    }

    ///* Generate the loader file
    var assetBuilder = AppStringsLoaderGenerator(fieldTree: sourceTree);
    var fileContent = assetBuilder.build();

    ///* Write the generated loader file
    var newPath = p.withoutExtension(buildStep.inputId.path).replaceAll(".importer", "");
    var filePath = p.setExtension(newPath, ".loader.dart");
    var sourceFile = File(filePath);
    sourceFile.writeAsString(fileContent);
  }
}
// endregion
