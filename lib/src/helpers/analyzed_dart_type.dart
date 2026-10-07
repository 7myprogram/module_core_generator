import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'import_alias_map.dart';

class AnalyzedDartType {
  final DartType value;
  final LibraryElement? library;
  final String? alias;

  AnalyzedDartType({required this.value})
    : library = value.element?.library,
      alias = _getAlias(value);

  String get nameWithAlias =>
      "${alias == null ? "" : "$alias."}${value.toString()}";

  static String? _getAlias(DartType type) {
    return ImportAliasMap().getAliasByType(type);
  }
}
