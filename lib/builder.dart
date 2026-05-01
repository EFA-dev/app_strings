// 1
import 'package:app_strings/src/builders/efa_lang_import_builder.dart';
import 'package:app_strings/src/builders/efa_lang_json_builder.dart';
import 'package:app_strings/src/builders/efa_lang_key_builder.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder efaLangImportBuilder(BuilderOptions options) {
  return LibraryBuilder(EFALangImportBuilder(), generatedExtension: '.efa.importer.dart');
}

Builder efaLangKeyBuilder(BuilderOptions options) {
  return LibraryBuilder(EFALangKeyBuilder(), generatedExtension: '.efa.key.dart');
}

Builder efaLangJsonBuilder(BuilderOptions options) {
  return LibraryBuilder(EFALangJsonBuilder(), generatedExtension: '.efa.json_temp.dart');
}

// Builder efaLangLoaderBuilder(BuilderOptions options) {
//   return LibraryBuilder(EFALangLoaderBuilder(), generatedExtension: '.efa.loader.dart');
// }
