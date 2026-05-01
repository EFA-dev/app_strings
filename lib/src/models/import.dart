class Import {
  const Import({
    required this.locale,
    required this.path,
  });

  /// The locale of the language fields
  /// Example: "en_US"
  final String locale;

  /// The path of the language fields
  /// Example: "lib/lang/imports/en_US.json"
  final String path;
}
