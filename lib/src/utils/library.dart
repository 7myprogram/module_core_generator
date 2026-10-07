import 'package:analyzer/dart/element/element.dart';

class Library {
  // 指定されたファイルでexportされているファイル名を再帰的に取得する
  static List<LibraryElement> getAllExportFiles(LibraryElement? library) {
    if (library == null) {
      return [];
    }

    final exportList = <LibraryElement>[];
    for (final libraryExport in library.firstFragment.libraryExports) {
      final temp = libraryExport.exportedLibrary;
      if (temp != null) {
        exportList.add(temp);
      }
      exportList.addAll(getAllExportFiles(libraryExport.exportedLibrary));
    }
    return exportList;
  }
}
