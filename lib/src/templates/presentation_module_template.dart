import 'package:module_core_generator/src/configs/presentation_module_generation_config.dart';

class PresentationModuleTemplate {
  PresentationModuleTemplate({required this._config});

  final PresentationModuleGenerationConfig _config;

  @override
  String toString() {
    final interfaceName = "\$I${_config.moduleName}PresentationModule";
    final viewBuilders = _config.viewBuilders;
    return '''
      abstract class $interfaceName {
        ${viewBuilders.map((elem) => "${_makeBuildScreenFunctionDefinition(elem.$1, elem.$2)};").toList().join("\n")}
      }

      final class _\$${_config.moduleName}PresentationModule with PresentationModule implements $interfaceName {
        @override
        void registerViewBuilder(ViewBuilderCollection collection) {
          ${viewBuilders.map((elem) => "collection.register(${elem.$1}());").toList().join("\n")}
        }

        ${viewBuilders.map((elem) => '''
          @override
          ${_makeBuildScreenFunctionDefinition(elem.$1, elem.$2)} {
            return getViewBuilder<${elem.$1}>().buildScreen(args);
          }
          ''').toList().join("\n")}
      } 
    ''';
  }

  String _makeBuildScreenFunctionDefinition(String builder, String screen) {
    return "$screen build${screen.replaceAll(RegExp(r'^.*\.'), '')}By${builder.replaceAll(RegExp(r'^.*\.'), '')}(dynamic args)";
  }
}
