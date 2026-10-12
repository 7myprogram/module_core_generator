import 'package:module_core_generator/src/configs/core_generation_config.dart';

class CoreTemplate {
  CoreTemplate({required this._config});

  final CoreGenerationConfig _config;

  @override
  String toString() {
    return '''
    ${_config.moduleName}Product create${_config.moduleName}() => ${_config.moduleName}Product();

    class ${_config.moduleName}Product extends Core<
      \$I${_config.moduleName}DataModule,
      \$I${_config.moduleName}DomainModule,
      \$I${_config.moduleName}PresentationModule
    > {
      ${_config.moduleName}Product()
        :super(
          data: _\$${_config.moduleName}DataModule(),
          domain: _\$${_config.moduleName}DomainModule(),
          presentation: _\$${_config.moduleName}PresentationModule(),
        );
    }
    ''';
  }
}
