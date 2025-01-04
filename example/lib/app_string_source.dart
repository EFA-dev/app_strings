// ignore_for_file: non_constant_identifier_names, type_annotate_public_apis

import 'package:app_strings/app_strings.dart';

@AppStringsConfig(json: true)
class AppStringsSource {
  var user = (
    gender: (
      male: (
        en_US: "Hi {} ;) ",
        tr_TR: "Merhaba {} ;) ",
      ),
      female: (
        en_US: "Hello :)",
        tr_TR: "Merhaba :)",
      ),
      other: (
        en_US: "Hello {}",
        tr_TR: "Merhaba {}",
      ),
    ),
    money: (
      zero: (
        en_US: "You not have money",
        tr_TR: "Paran yok",
      ),
      one: (
        en_US: "You have {} dollar",
        tr_TR: "Senin {} doların var",
      ),
      many: (
        en_US: "You have {} dollars",
        tr_TR: "Senin {} doların var",
      ),
      other: (
        en_US: "You have {} dollars",
        tr_TR: "Senin {} doların var",
      ),
    ),
  );

  var incomeTransaction = (
    fields: (
      amount: (
        en_US: "Price",
        tr_TR: "Fiyat",
      ),
      paymentDate: (
        en_US: "Payment Date",
        tr_TR: "Ödeme Tarihi",
      ),
    ),
    actions: (
      update: (
        en_US: "Edit",
        tr_TR: "Düzenle",
      ),
      detail: (
        en_US: "Detail",
        tr_TR: "Detay",
      ),
      addTag: (
        en_US: "Add Tag",
        tr_TR: "Etiket Ekle",
      ),
    ),
    validations: (
      amount: (
        notNull: (
          en_US: "You must enter an amount",
          tr_TR: "Bir miktar girmelisiniz",
        ),
        lessThen: (
          en_US: "Amount must be less than 100",
          tr_TR: "Miktar 100'den az olmalı",
        ),
      ),
    ),
  );

  var expenseTransaction = (
    fields: (
      amount: (
        en_US: "Price",
        tr_TR: "Fiyat",
      ),
      paymentDate: (
        en_US: "Payment Date",
        tr_TR: "Ödeme Tarihi",
      ),
    ),
  );
}
