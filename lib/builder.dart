// 1
import 'package:app_strings/src/builders/app_strings_import_builder.dart';
import 'package:app_strings/src/builders/app_strings_json_builder.dart';
import 'package:app_strings/src/builders/app_strings_key_builder.dart';
import 'package:app_strings/src/builders/app_strings_loader_builder.dart';
import 'package:app_strings/src/builders/efa_lang_import_builder.dart';
import 'package:app_strings/src/builders/efa_lang_json_builder.dart';
import 'package:app_strings/src/builders/efa_lang_key_builder.dart';
import 'package:app_strings/src/builders/efa_lang_loader_builder.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder importBuilder(BuilderOptions options) {
  return LibraryBuilder(AppStringsImportBuilder(), generatedExtension: '.importer.dart');
}

Builder keyBuilder(BuilderOptions options) {
  return LibraryBuilder(AppStringsKeyBuilder(), generatedExtension: '.key.dart');
}

Builder loaderBuilder(BuilderOptions options) {
  return LibraryBuilder(AppStringsLoaderBuilder(), generatedExtension: '.loader.dart');
}

Builder jsonBuilder(BuilderOptions options) {
  return LibraryBuilder(AppStringsJsonBuilder(), generatedExtension: '.json_temp.dart');
}

Builder efaLangImportBuilder(BuilderOptions options) {
  return LibraryBuilder(EFALangImportBuilder(), generatedExtension: '.efa.importer.dart');
}

Builder efaLangKeyBuilder(BuilderOptions options) {
  return LibraryBuilder(EFALangKeyBuilder(), generatedExtension: '.efa.key.dart');
}

Builder efaLangLoaderBuilder(BuilderOptions options) {
  return LibraryBuilder(EFALangLoaderBuilder(), generatedExtension: '.efa.loader.dart');
}

Builder efaLangJsonBuilder(BuilderOptions options) {
  return LibraryBuilder(EFALangJsonBuilder(), generatedExtension: '.efa.json_temp.dart');
}
