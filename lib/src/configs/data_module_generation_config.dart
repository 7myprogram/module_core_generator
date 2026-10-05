class DataModuleGenerationConfig {
  DataModuleGenerationConfig({
    required this.moduleName,
    required this.dataSourceNames,
    required this.repositoryNames,
  });

  final String moduleName;
  final List<(String, String)> dataSourceNames;
  final List<(String, String)> repositoryNames;
}
