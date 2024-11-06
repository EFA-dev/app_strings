// 1
import 'package:app_strings/src/builders/app_strings_import_builder.dart';
import 'package:app_strings/src/builders/app_strings_json_builder.dart';
import 'package:app_strings/src/builders/app_strings_key_builder.dart';
import 'package:app_strings/src/builders/app_strings_loader_builder.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder appStringsImportBuilder(BuilderOptions options) => LibraryBuilder(AppStringsImportBuilder(), generatedExtension: '.importer.dart');
Builder appStringsLoaderBuilder(BuilderOptions options) => LibraryBuilder(AppStringsLoaderBuilder(), generatedExtension: '.loader.dart');
Builder appStringsKeyBuilder(BuilderOptions options) => LibraryBuilder(AppStringsKeyBuilder(), generatedExtension: '.key.dart');
Builder appStringsJsonBuilder(BuilderOptions options) => LibraryBuilder(AppStringsJsonBuilder(), generatedExtension: '.json');
