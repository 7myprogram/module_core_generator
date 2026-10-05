import 'package:module_core_generator/src/configs/data_module_generation_config.dart';

class DataModuleTemplate {
  DataModuleTemplate({required this._config});

  final DataModuleGenerationConfig _config;

  @override
  String toString() {
    final interfaceName = "\$I${_config.moduleName}DataModule";
    return '''
      abstract class $interfaceName {}

      final class _\$${_config.moduleName}DataModule with DataModule implements $interfaceName {
        @override
        void registerDataSources(DataSourceCollection dataSourceCollection) {
          ${_config.dataSourceNames.map((elem) => 'dataSourceCollection.register<${elem.$1}>(${elem.$2}());').toList().join("\n")}
        }

        @override
        void registerRepositories(RepositoryCollection repositoryCollection) {
          ${_config.repositoryNames.map((elem) => 'repositoryCollection.register<${elem.$1}>(${elem.$2}());').toList().join("\n")}
        }
      } 
    ''';
  }
}
