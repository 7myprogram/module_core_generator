class DataModuleGenerationConfig {
  DataModuleGenerationConfig({
    required this.moduleName,
    required this.dataSourceNames,
    required this.repositoryNames,
    this.interfaceName,
  });

  final String moduleName;
  final String? interfaceName;
  final List<(String, String)> dataSourceNames;
  final List<(String, String)> repositoryNames;
}
