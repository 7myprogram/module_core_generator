import 'package:module_core_generator/src/configs/core_generation_config.dart';

class CoreTemplate {
  CoreTemplate({required this._config});

  final CoreGenerationConfig _config;

  @override
  String toString() {
    return '''
    \$${_config.moduleName}Core create${_config.moduleName}() => \$${_config.moduleName}Core();

    class \$${_config.moduleName}Core extends Core<
      \$I${_config.moduleName}DataModule,
      \$I${_config.moduleName}DomainModule,
      \$I${_config.moduleName}PresentationModule
    > {
      \$${_config.moduleName}Core()
        :super(
          data: _\$${_config.moduleName}DataModule(),
          domain: _\$${_config.moduleName}DomainModule(),
          presentation: _\$${_config.moduleName}PresentationModule(),
        );
    }
    ''';
  }
}
