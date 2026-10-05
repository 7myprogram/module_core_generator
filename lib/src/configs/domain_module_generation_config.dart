class DomainModuleGenerationConfig {
  DomainModuleGenerationConfig({
    required this.moduleName,
    required this.usecaseNames,
  });

  final String moduleName;
  final List<String> usecaseNames;
}
