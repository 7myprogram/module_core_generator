import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';

class ImportAliasMap {
  static final ImportAliasMap _instance = ImportAliasMap._();

  factory ImportAliasMap() {
    return _instance;
  }

  ImportAliasMap._();

  Map<String, String>? _map;

  void init(LibraryElement libraryElement) {
    if (_map != null) {
      return;
    }

    final Map<String, String> map = {};
    for (final libraryImport in libraryElement.firstFragment.libraryImports) {
      final key = libraryImport.importedLibrary?.identifier;
      final alias = libraryImport.prefix?.name;

      if (key == null || alias == null) {
        continue;
      }

      map[key] = alias;
      for (final fileName in _getAllExportFileNames(
        libraryImport.importedLibrary,
      )) {
        map[fileName] = alias;
      }
    }
    _map = map;
  }

  String? getAliasByType(DartType? object) {
    final map = _map;
    final key = object?.element?.library?.identifier;
    if (key == null || map == null) {
      return null;
    }
    return map[key];
  }

  // 指定されたファイルでexportされているファイル名を再帰的に取得する
  static List<String> _getAllExportFileNames(LibraryElement? library) {
    if (library == null) {
      return [];
    }

    final exportList = <String>[];
    for (final libraryExport in library.firstFragment.libraryExports) {
      final temp = libraryExport.exportedLibrary?.identifier;
      if (temp != null) {
        exportList.add(temp);
      }
      exportList.addAll(_getAllExportFileNames(libraryExport.exportedLibrary));
    }
    return exportList;
  }
}
