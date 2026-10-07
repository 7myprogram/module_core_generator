import 'package:analyzer/dart/element/type.dart';

import 'import_alias_map.dart';

class AnalyzedDartType {
  static final fileSet = <String>{};
  final DartType value;
  final String? fileName;
  final String? alias;

  AnalyzedDartType({required this.value})
    : fileName = value.element?.library?.identifier,
      alias = _getAlias(value) {
    final temp = fileName;
    if (temp != null) {
      fileSet.add(temp);
    }
  }

  String get nameWithAlias =>
      "${alias == null ? "" : "$alias."}${value.toString()}";

  static String? _getAlias(DartType type) {
    return ImportAliasMap().getAliasByType(type);
  }
}
