import 'dart:convert';

// region [p]

/// EFAKey handles localization strings including Plural, Gender, and Template support.
class EFAKey {
  const EFAKey({required this.path, required this.data});

  /// The unique localization path (e.g., "income.actions.add")
  final String path;

  /// A function that returns a map of locales and their corresponding translation strings.
  /// The value can be a plain string or a JSON string for Plurals/Gender.
  final Map<String, String> Function() data;

  /// Main translation method that processes arguments, gender, and plural counts.
  String tr({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
    num? count,
  }) {
    // Get the raw string for the current active locale.
    // EFALangManager represents your system's locale management.
    final String rawValue = data()["tr_TR"] ?? path;

    String result = rawValue;

    // Check if the string is a complex structure (JSON) for Gender or Plural logic.
    if (rawValue.trim().startsWith('{')) {
      try {
        final Map<String, dynamic> decoded = json.decode(rawValue);
        result = _resolveComplexStructure(decoded, gender: gender, count: count);
      } catch (e) {
        // Fallback to raw value if JSON decoding fails.
        result = rawValue;
      }
    }

    // Process template replacements for arguments.
    return _replaceArgs(result, args: args, namedArgs: namedArgs);
  }

  // EFAKey içine eklenebilir
  String plural(num count, {List<String>? otherArgs, Map<String, String>? namedArgs}) {
    return tr(
      count: count,
      // count değerini otomatik olarak ilk argüman yap, yanına varsa diğerlerini ekle
      args: [count.toString(), ...(otherArgs ?? [])],
      namedArgs: namedArgs,
    );
  }

  /// Selects the correct string based on reserved words (male, female, zero, one, etc.)
  String _resolveComplexStructure(
    Map<String, dynamic> map, {
    String? gender,
    num? count,
  }) {
    // 1. Priority: Plural (if count is provided)
    if (count != null) {
      final key = _getPluralKey(count);
      // Fallback hierarchy: specific key -> 'other' -> path
      return map[key]?.toString() ?? map['other']?.toString() ?? path;
    }

    // 2. Priority: Gender (if gender is provided)
    if (gender != null) {
      // Fallback hierarchy: specific gender -> 'other' -> path
      return map[gender]?.toString() ?? map['other']?.toString() ?? path;
    }

    // 3. Final Fallback
    return map['other']?.toString() ?? map.values.first.toString();
  }

  /// Determines the plural key based on the numeric count.
  /// Matches the 'reservedWords' list.
  String _getPluralKey(num count) {
    if (count == 0) return "zero";
    if (count == 1) return "one";
    if (count == 2) return "two";
    if (count > 2 && count < 5) return "few";
    if (count >= 5) return "many";
    return "other";
  }

  /// Replaces {} and {name} placeholders with provided arguments.
  String _replaceArgs(
    String text, {
    List<String>? args,
    Map<String, String>? namedArgs,
  }) {
    String result = text;

    // Sequential arguments: replaces {} in order.
    if (args != null && args.isNotEmpty) {
      for (var arg in args) {
        result = result.replaceFirst('{}', arg);
      }
    }

    // Named arguments: replaces {key} with value.
    if (namedArgs != null && namedArgs.isNotEmpty) {
      namedArgs.forEach((key, value) {
        result = result.replaceAll('{$key}', value);
      });
    }

    return result;
  }

  /// Convenience getter for simple translations.
  String get val => tr();

  @override
  String toString() => val;
}

// endregion
