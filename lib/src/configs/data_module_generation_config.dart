import 'package:module_core_generator/src/helpers/analyzed_dart_type.dart';

class DataModuleGenerationConfig {
  DataModuleGenerationConfig({
    required this.moduleName,
    required this.dataSources,
    required this.repositories,
  });

  final String moduleName;
  final List<(AnalyzedDartType, AnalyzedDartType)> dataSources;
  final List<(AnalyzedDartType, AnalyzedDartType)> repositories;
}
