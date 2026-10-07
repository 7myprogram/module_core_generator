import 'package:module_core_generator/src/configs/presentation_module_generation_config.dart';

class PresentationModuleTemplate {
  PresentationModuleTemplate({required this._config});

  final PresentationModuleGenerationConfig _config;

  @override
  String toString() {
    final interfaceName = "\$I${_config.moduleName}PresentationModule";
    final viewBuilderAndScreens = _config.viewBuilderAndScreens;
    return '''
      abstract class $interfaceName {
        ${viewBuilderAndScreens.map((elem) => "${_makeBuildScreenFunctionDefinition(elem.$1.nameWithAlias, elem.$2.nameWithAlias)};").toList().join("\n")}
      }

      final class _\$${_config.moduleName}PresentationModule with PresentationModule implements $interfaceName {
        @override
        void registerViewBuilder(ViewBuilderCollection collection) {
          ${viewBuilderAndScreens.map((elem) => "collection.register(${elem.$1.nameWithAlias}());").toList().join("\n")}
        }

        ${viewBuilderAndScreens.map((elem) => '''
          @override
          ${_makeBuildScreenFunctionDefinition(elem.$1.nameWithAlias, elem.$2.nameWithAlias)} {
            return getViewBuilder<${elem.$1.nameWithAlias}>().buildScreen(args);
          }
          ''').toList().join("\n")}
      } 
    ''';
  }

  String _makeBuildScreenFunctionDefinition(String builder, String screen) {
    return "$screen build${screen.replaceAll(RegExp(r'^.*\.'), '')}By${builder.replaceAll(RegExp(r'^.*\.'), '')}(dynamic args)";
  }
}
