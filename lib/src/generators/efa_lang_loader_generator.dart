import 'package:app_strings/src/models/field_tree.dart';
import 'package:app_strings/src/utils/formatter.dart';
import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';

//#region [p]

class EFALangLoaderGenerator {
  EFALangLoaderGenerator({
    required this.fieldTree,
    required this.className,
  });

  final FieldTree fieldTree;
  final String className;

  Set<String> get locales => fieldTree.locales;

  String build() {
    var library = Library(
      (library) => library
        ..ignoreForFile.add("constant_identifier_names")
        ..directives.addAll(
          [
            Directive.import('package:efa_core/efa_core.dart'),
          ],
        )
        ..body.addAll(
          [
            refer("// region [p] \n\n"),
            Class(
              (c) => c
                ..name = "${className}Loader"
                ..extend = refer('EFALangLoader')
                ..constructors = ListBuilder(
                  [
                    Constructor(
                      (b) => b..constant = true,
                    ),
                  ],
                )

                /// EFAKey'in erişeceği zorunlu getter
                ..methods.add(
                  Method(
                    (m) => m
                      ..name = 'locales'
                      ..annotations.add(refer("override"))
                      ..type = MethodType.getter
                      ..returns = refer("Map<String, Map<String, dynamic>>")
                      // lambda: => mapLocales;
                      ..lambda = true
                      ..body = const Code("mapLocales"),
                  ),
                )
                ..fields.addAll([
                  Field(
                    (p0) => p0
                      ..modifier = FieldModifier.constant
                      ..static = true
                      ..type = refer("Map<String, Map<String, dynamic>>")
                      ..name = "mapLocales"
                      ..assignment = literalMap(_buildLocales()).code,
                  ),
                  ...locales.map(
                    (locale) => Field(
                      (p0) => p0
                        ..modifier = FieldModifier.constant
                        ..static = true
                        ..type = refer("Map<String, dynamic>")
                        ..name = locale
                        ..assignment = literalMap(_buildField(locale)).code,
                    ),
                  ),
                ]),
            ),
            refer("\n // [endregion]"),
          ],
        ),
    );

    return Formatter.format(library);
  }

  /// Build locales map
  Map<String, dynamic> _buildLocales() {
    var map = <String, dynamic>{};

    var mapEntries = locales.map((locale) => MapEntry(locale, refer(locale)));
    map.addEntries(mapEntries);

    return map;
  }

  ///Builds Record type fields
  Map<String, dynamic> _buildField(String locale) {
    var map = <String, dynamic>{};

    var mapEntries = fieldTree.fields.map((field) {
      return MapEntry(
        field.name,
        _buildSubField(field.children, locale),
      );
    }).toList();

    map.addEntries(mapEntries);

    return map;
  }

  ///Builds sub children
  dynamic _buildSubField(List<FieldNode> children, String locale) {
    var map = <String, dynamic>{};

    for (var field in children) {
      if (field.valueNode && field.name == locale) {
        return field.value;
      } else {
        MapEntry<String, Object?> mapEntry;
        mapEntry = MapEntry(field.name, _buildSubField(field.children, locale));
        map.addEntries([mapEntry]);
      }
    }

    return map;
  }
}

//#endregion
