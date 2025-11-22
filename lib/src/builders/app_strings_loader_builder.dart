import 'package:analyzer/dart/element/element.dart';
import 'package:app_strings/app_strings.dart';
import 'package:app_strings/src/generators/app_strings_loader_generator.dart';
import 'package:app_strings/src/models/field_tree.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

// region [p]
class AppStringsLoaderBuilder extends GeneratorForAnnotation<AppStringsConfig> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
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

    return fileContent;
  }
}
// endregion
