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
    final typeElement = type.element;
    if (typeElement == null) {
      return null;
    }
    for (final frag in library.fragments) {
      for (final libImp in frag.libraryImports) {
        final alias = libImp.prefix?.name;
        final importedElement = libImp.importedLibrary?.exportNamespace.get2(
          typeElement.displayName,
        );
        if (alias == null || importedElement == null) {
          continue;
        }
        if (importedElement == typeElement) {
          return alias;
        }
      }
    }
    return null;
  }
}
