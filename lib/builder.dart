// 1
import 'package:app_strings/src/builders/app_strings_import_builder.dart';
import 'package:app_strings/src/builders/app_strings_json_builder.dart';
import 'package:app_strings/src/builders/app_strings_key_builder.dart';
import 'package:app_strings/src/builders/app_strings_loader_builder.dart';
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
  return LibraryBuilder(AppStringsJsonBuilder(), generatedExtension: '.temp.dart');
}
