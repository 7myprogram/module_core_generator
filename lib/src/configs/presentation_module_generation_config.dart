class PresentationModuleGenerationConfig {
  PresentationModuleGenerationConfig({
    required this.moduleName,
    required this.viewBuilders,
  });

  final String moduleName;

  // first: Builderの型名、second: 出力されるScreenの型
  final List<(String, String)> viewBuilders;
}
