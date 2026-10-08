import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'library_analyzer.dart';

class AnalyzedDartType {
  final DartType value;
  final LibraryElement? library;
  final String? alias;

  AnalyzedDartType({required this.value})
    : library = value.element?.library,
      alias = LibraryAnalyzer().getAlias(value);

  String get nameWithAlias =>
      "${alias == null ? "" : "$alias."}${value.toString()}";
}
