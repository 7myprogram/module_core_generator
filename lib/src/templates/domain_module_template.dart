import 'package:module_core_generator/src/configs/domain_module_generation_config.dart';

class DomainModuleTemplate {
  DomainModuleTemplate({required this._config});

  final DomainModuleGenerationConfig _config;

  @override
  String toString() {
    final interfaceName = _config.interfaceName;
    return '''
      final class _\$${_config.moduleName}DomainModule with DomainModule ${interfaceName == null ? '' : 'implements $interfaceName'} {
        @override
        void registerUsecases(UsecaseCollection collection) {
          ${_config.usecaseNames.map((elem) => 'collection.register($elem());').toList().join("\n")}
        }
      } 
    ''';
  }
}
