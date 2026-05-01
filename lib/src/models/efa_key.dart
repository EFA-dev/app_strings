// region [p]

typedef EFADataMapCallback = Map<String, String> Function();

class EFAKey {
  final String path;
  final EFADataMapCallback data; // () => {"en_US": "Income", "tr_TR": "Gelir"}

  const EFAKey({required this.path, required this.data});

  /// Mimariyle konuşan ve Map içinden hızlıca veriyi çeken getter
  String get val {
    // 1. EFA Genel mimarisinden aktif dili al (Örn: "tr_TR")
    final activeLocale = "tr_TR";

    // 2. Fonksiyonu çalıştır ve Map'i al (Sadece ihtiyaç anında RAM'e biner)
    final translations = data();

    // 3. Map içinden dile göre veriyi çek, yoksa path'i dön
    return translations[activeLocale] ?? translations['en_US'] ?? path;
  }

  @override
  String toString() => val;
}

// endregion
