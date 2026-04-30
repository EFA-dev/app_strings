// region [p]

///* Annotation for the EFALang localization configuration.
///* Classes marked with this attribute will be analyzed by Analyzer 13
///* to generate type-safe key structures and translation tables.
class EFALang {
  const EFALang({
    this.generateJson = false,
    this.generateEasyLoader = false,
    this.import,
    this.removeLocale,
    this.addRegionComments = true,
  });

  ///* Exports translation fields as JSON files under 'assets/translations/'.
  ///* Useful for external translation tools or legacy support.
  final bool generateJson;

  ///* Exports translation fields as a Dart file compatible with the easy_localization loader.
  final bool generateEasyLoader;

  ///* Used to import localization data from an external JSON file into the current class.
  ///* Example: EFAImport(locale: "en_US", path: "lib/lang/imports/en_US.json")
  final EFAImport? import;

  ///* Excludes a specific locale from the generation process.
  ///* Example: "en_US"
  final String? removeLocale;

  ///* Wraps the generated code blocks with '// region [p]' comments for EFA standards.
  final bool addRegionComments;
}

///* Configuration for importing external localization data.
class EFAImport {
  const EFAImport({
    required this.locale,
    required this.path,
  });

  ///* The language code (e.g., "en_US").
  final String locale;

  ///* The physical path of the JSON file (e.g., "assets/temp/en_US.json").
  final String path;
}

// endregion
