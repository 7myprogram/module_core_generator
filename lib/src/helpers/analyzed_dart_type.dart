import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as package_path;
import 'package:module_core_generator/src/utils/library.dart';

import 'import_alias_map.dart';

class AnalyzedDartType {
  static final _analyzedDartTypeList = <AnalyzedDartType>[];
  final DartType value;
  final LibraryElement? library;
  final String? alias;

  AnalyzedDartType({required this.value})
    : library = value.element?.library,
      alias = _getAlias(value) {
    final temp = library;
    if (temp != null) {
      _analyzedDartTypeList.add(this);
    }
  }

  String get nameWithAlias =>
      "${alias == null ? "" : "$alias."}${value.toString()}";

  static String? _getAlias(DartType type) {
    return ImportAliasMap().getAliasByType(type);
  }

  static String getImportLines(String outputDirPath) {
    final exportedFiles = <String>{};
    final Map<String, (String, String?)> importMap = {};
    for (final type in _analyzedDartTypeList) {
      final library = type.library;
      if (library == null) {
        continue;
      }

      String path = "";
      if (RegExp(r'^package').hasMatch(library.identifier)) {
        path = library.identifier;
      } else if (RegExp(r'^asset').hasMatch(library.identifier)) {
        path = package_path
            .relative(library.uri.path, from: outputDirPath)
            .replaceAll(r'\', '/');
      } else {
        path = library.uri.path;
      }

      importMap[library.identifier] = (path, type.alias);

      // 他ファイルでexportされているファイルを探す。
      for (final file in Library.getAllExportFiles(library)) {
        exportedFiles.add(file.identifier);
      }
    }

    String importLines = "import 'package:module_core/module_core.dart';\n";
    for (final entry in importMap.entries) {
      // 重複importを防ぐ
      if (exportedFiles.contains(entry.key)) {
        continue;
      }
      importLines +=
          "import '${entry.value.$1}${entry.value.$2 == null ? "';\n" : "' as ${entry.value.$2};\n"}";
    }

    return importLines;
  }
}
