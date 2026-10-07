import 'package:module_core_generator/src/helpers/analyzed_dart_type.dart';

class PresentationModuleGenerationConfig {
  PresentationModuleGenerationConfig({
    required this.moduleName,
    required this.viewBuilderAndScreens,
  });

  final String moduleName;

  // first: Builderの型名、second: 出力されるScreenの型
  final List<(AnalyzedDartType, AnalyzedDartType)> viewBuilderAndScreens;
}
