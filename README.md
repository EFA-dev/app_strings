A build_runner package for managing app language files.

This package helps you to manage your app's language files in a single Dart file. It enables you to generate JSON files or easy_localization key and loader classes from the Dart file.

## Features

1. Combine translations in a single Dart file
2. Generates JSON files for each locale
3. Generates easy_localization loader class
4. Generate key file for key paths
5. Import new locale from a JSON file
6. Remove a locale from the source file
7. Continuously generate files with the watch command

<br />

## Getting started

---

- Add app_strings to pubspec.yaml file under the dependencies section

```yaml
  dependencies:   
    app_strings: latest
```

- Add build_runner to pubspec.yaml file under the dev_dependencies section

```yaml
  dev_dependencies:
    build_runner: latest

```

- Add easy_localization if you want to use easy localization loader

```yaml
  dependencies:
    app_strings: latest   
    easy_localization: latest
```

<br />

## Usage

1- Create a Dart file in `lib/lang/app_strings_source.dart` copy and past codes below.
You can change the source file location. Details are provided below.

```dart
// ignore_for_file: non_constant_identifier_names, type_annotate_public_apis

import 'package:app_strings/app_strings.dart';

@AppStringsConfig(json: true, easyLoader: true)
class AppStringsSource {
  var user = (
    gender: (
      male: (en_US: "Hi man {} ;) ",),
      female: (en_US: "Hello girl :)",),
      other: (en_US: "Hello {}",),
    ),
    money: (
      zero: (en_US: "You not have money",),
      one: (en_US: "You have {} dollar",),
      many: (en_US: "You have {} dollars",),
      other: (en_US: "You have {} dollars",),
    ),
  );

  var incomeTransaction = (
    fields: (
      amount: (en_US: "Price",),
      paymentDate: (en_US: "Payment Date",),
    ),
    actions: (
      update: (en_US: "Edit",),
      detail: (en_US: "Detail",),
      addTag: (en_US: "Add Tag",),
    ),
    validations: (
      amount: (
        notNull: (en_US: "You must enter an amount",),
        lessThen: (en_US: "Amount must be less than 100",),
      ),
    ),
  );

  var expenseTransaction = (
    fields: (
      amount: (en_US: "Price",),
      paymentDate: (en_US: "Payment Date",),
    ),
  );
}


```

> [!IMPORTANT]
>
> - Fields should be a Record
> - The last node(value node) should contain the locale as a parameter name and value should be a String
> - `zero`, `one`, `two`, `few`, `many`, `other`, `male`, `female` are reserved words. They should be the first parent of the value node.
> - If you use one of the reserved words and you are using the easy_localization package, `other` is required

---

<br />

2 - Run `dart run build_runner build --delete-conflicting-outputs `

The package will create files below in the same directory

- `app_strings_source.en_US.json` is a asset file you can use with easy_localization or some other packages which does support JSON assets
- `app_strings_source.loader.dart` is a easy_localization loader file. You can use it to load your translations.
- `app_strings_source.key.dart` is a Dart file that contains AppStrings class and keys in it to access translations

<br />

## AppStringsConfig Parameters


| Param               | Type    | Default    | Description                                                                   |
| ------------------- | ------- | ---------- | ----------------------------------------------------------------------------- |
| `keyClassName`      | String  | AppStrings | Name for keys class                                                           |
| `easyLoader`        | bool    | false      | Generates easy loader class                                                   |
| `json`              | bool    | false      | Generates JSON files for each locale                                          |
| `remove`            | String? | null       | Removes a locale from the source file                                         |
| `import`            | Import? | null       | Import a new locale from a JSON file                                          |
| `addRegionComments` | bool    | false      | Add region comments to generated dart files for Colored Regions VSCode plugin |

<br />

## Import New Locale

You can import a new locale with a JSON file. When you import a new local, the files will generated again with new translations.

- If the source file contains a local already, existing keys will be use to import the new locale. If new locale json file doesn't contains any key that already exist, will be ignored.
- If the source file is empty, the keys will be generated from the JSON

```dart
import 'package:app_strings/app_strings.dart';


@AppStringsConfig(import: Import(locale: "en_US", path: "lib/lang/imports/en_US.json",json: true, easyLoader: true,))
class AppStringsSource {   
     // Fields ...  
}

```

> [!WARNING]
> After import you should remove the import parameter

<br />

## Remove Existing Locale

You can remove an existing locale from the sourcefile with `remove` parameter of `AppStringsConfig` annotation.

When you remove a locale, all files will be generated again.

```dart

import 'package:app_strings/app_strings.dart';


@AppStringsConfig(remove: "en_US", json: true, easyLoader: true)
class AppStringsSource {
    // Fields ...
}

```

<br />

## Watch

With `dart run build_runner watch --delete-conflicting-outputs` command, you can watch the source file and generate files automatic while you are working.

If you use [localization_pro](https://pub.dev/packages/localization_pro) package you can install new JSON files and see the changes on app instantly without restart the app.

## Source File Location

Default source file locations are `lib/lang/SOURCE_FILE_NAME.dart` and `lib/generated/SOURCE_FILE_NAME.dart`.
If you put your source file in these locations, you don't need to specify the source file location.

If you want to change the source file location, you can create a `build.yaml` file at the root of the project. This file allows you to specify custom paths for the source files that the `app_strings` package will process. Below is an example configuration for the `build.yaml` file:

> [!WARNING]
> The path should be the same for all builders

```yaml
targets:
  $default:
    builders:
      app_strings|importer_builder:
        enabled: true
        generate_for:
          include:
            - lib/CUSTOM_FOLDER/*.dart
      app_strings|key_builder:
        enabled: true
        generate_for:
          include:
            - lib/CUSTOM_FOLDER/*.dart
      app_strings|loader_builder:
        enabled: true
        generate_for:
          include:
            - lib/CUSTOM_FOLDER/*.dart
      app_strings|json_builder:
        enabled: true
        generate_for:
          include:
            - lib/CUSTOM_FOLDER/*.dart
```

## Decrease the build time

To decrease build time, you can disable builders that you don't need. For example, if you don't use easy_localization, you can disable the loader_builder.
Disabling a builder will cause the `easyLoader` or `json` parameters in the `AppStringsConfig` annotation to be ignored.

```yaml
targets:
  $default:
    builders:
      app_strings|importer_builder:
        enabled: false
   
      app_strings|key_builder:
        enabled: true

      app_strings|loader_builder:
        enabled: false

      app_strings|json_builder:
        enabled: true
```


## Builders

| Builder            | Description                                                                  |
| ------------------ | ---------------------------------------------------------------------------- |
| `importer_builder` | Imports new locales from JSON files and updates the source file accordingly. |
| `key_builder`      | Generates a Dart file containing keys for accessing translations.            |
| `loader_builder`   | Generates an easy_localization loader class for loading translations.        |
| `json_builder`     | Generates JSON files for each locale from the source Dart file.              |