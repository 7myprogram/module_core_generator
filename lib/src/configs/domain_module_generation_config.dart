import 'package:module_core_generator/src/helpers/analyzed_dart_type.dart';

class DomainModuleGenerationConfig {
  DomainModuleGenerationConfig({
    required this.moduleName,
    required this.usecases,
  });

  final String moduleName;
  final List<AnalyzedDartType> usecases;
}
