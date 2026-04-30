// region [p]

abstract class EFALangLoader {
  const EFALangLoader();
  Map<String, Map<String, dynamic>> get locales;

  String translate(String path) {
    // 1. Get current language from a global setting (EFA.locale gibi)
    // final currentLang = EFALocaleManager.instance.currentLocale;
    final data = locales["tr_TR"] ?? {};

    // 2. Simple path traversal (income -> title)
    final keys = path.split('.');
    dynamic current = data;

    for (var key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return path;
      }
    }
    return current.toString();
  }
}

// endregion
