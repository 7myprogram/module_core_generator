import 'package:module_core_generator/src/configs/data_module_generation_config.dart';

class DataModuleTemplate {
  DataModuleTemplate({required this._config});

  final DataModuleGenerationConfig _config;

  @override
  String toString() {
    final interfaceName = _config.interfaceName;
    return '''
      final class _\$${_config.moduleName}DataModule with DataModule ${interfaceName == null ? '' : 'implements $interfaceName'} {} 
''';
  }
}
/* 
print(element.fields[0].name);
    final dataSources = element.fields[0].computeConstantValue();
    final temp = dataSources!.toListValue();

    for (int i = 0; i < temp!.length; ++i) {
      print(temp[i]);
      final t = temp[i].toTypeValue();
      final c = t!.element as ClassElement?;
      print(c?.interfaces);
    }
 */
