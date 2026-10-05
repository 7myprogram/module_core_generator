class DomainModuleGenerationConfig {
  DomainModuleGenerationConfig({
    required this.moduleName,
    required this.usecaseNames,
    this.interfaceName,
  });

  final String moduleName;
  final String? interfaceName;
  final List<String> usecaseNames;
}
