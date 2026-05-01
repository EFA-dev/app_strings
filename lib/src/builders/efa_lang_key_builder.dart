// region [p]

import 'package:analyzer/dart/element/element.dart';
import 'package:app_strings/src/annotations/efa_lang.dart';
import 'package:app_strings/src/generators/efa_lang_key_generator.dart';
import 'package:app_strings/src/models/field_tree.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

///* Builder responsible for coordinating the EFALang generation process.
class EFALangKeyBuilder extends GeneratorForAnnotation<EFALang> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) async {
    ///* Build the FieldTree from the source file
    var sourceTree = await FieldTree.fromAst(buildStep);
    if (sourceTree == null) {
      return null;
    }

    ///* Get the key class name
    // final keyClassName = annotation.read("keyClassName").stringValue;

    // var loaderClassName = "${className}Loader";
    // final loaderPath = buildStep.inputId.changeExtension('.efa.loader.dart').uri.toString();

    var className = element.displayName.replaceAll("_", "");

    ///* Generate the key file
    var keyBuilder = EFALangKeyGenerator(
      fieldTree: sourceTree,
      className: className,
    );
    var fileContent = keyBuilder.build();

    return fileContent;
  }
}

// endregion
