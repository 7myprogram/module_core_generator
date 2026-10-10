import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class AnalyzedDartType {
  final DartType value;
  final LibraryElement? library;
  final String? alias;

  AnalyzedDartType({required this.value, required this.alias})
    : library = value.element?.library;

  String get nameWithAlias =>
      "${alias == null ? "" : "$alias."}${value.toString()}";
}
