// region [p]

import 'package:app_strings/src/models/efa_lang_loader.dart';

class EFAKey {
  const EFAKey(this.path, this.loader);

  final String path;
  final EFALangLoader loader;

  String get tr {
    return loader.translate(path);
  }
}

// endregion
