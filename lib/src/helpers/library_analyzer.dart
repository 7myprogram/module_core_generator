import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';

class LibraryAnalyzer {
  final LibraryElement library;

  LibraryAnalyzer({required this.library});

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
