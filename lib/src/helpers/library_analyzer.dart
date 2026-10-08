import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';

class LibraryAnalyzer {
  late final LibraryElement library;
  static final LibraryAnalyzer _instance = LibraryAnalyzer._();

  factory LibraryAnalyzer() {
    return _instance;
  }

  LibraryAnalyzer._();

  void init(LibraryElement lib) {
    library = lib;
  }

  String? getAlias(DartType type) {
    for (final frag in library.fragments) {
      for (final libImp in frag.libraryImports) {
        final alias = libImp.prefix?.name;
        if (alias == null) {
          continue;
        }
        final impLib = libImp.importedLibrary;
        if (impLib != null && _checkExport(impLib, type)) {
          return alias;
        }
      }
    }
    return null;
  }

  bool _checkExport(LibraryElement lib, DartType type) {
    for (final frag in lib.fragments) {
      for (final libExp in frag.libraryExports) {
        final expLib = libExp.exportedLibrary;
        if (expLib?.identifier == type.element?.library?.identifier) {
          return true;
        }
        if (expLib != null && _checkExport(expLib, type)) {
          return true;
        }
      }
    }
    return false;
  }
}
