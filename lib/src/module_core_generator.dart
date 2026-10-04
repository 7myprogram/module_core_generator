import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:module_core_annotation/module_core_annotation.dart';

import 'utils/entrypoint.dart';
import 'configs/entrypoint.dart';
import 'templates/entrypoint.dart';

class ModuleCoreGenerator extends GeneratorForAnnotation<ModuleCore> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@ModuleCore以外の処理不可 ${element.name}',
        element: element,
      );
    }

    final library = await buildStep.resolver.libraryFor(buildStep.inputId);

    final dataModuleBuffer = StringBuffer()
      ..writeln(_writeDataModule(element, library));

    return dataModuleBuffer.toString();
  }

  String _writeDataModule(ClassElement element, LibraryElement library) {
    final className = element.displayName;
    final fields = element.fields;

    String? interfaceName;

    final libraryImports = library.firstFragment.libraryImports;
    for (int i = 0; i < libraryImports.length; ++i) {
      final importData = libraryImports[i];
      print(importData.toString());
      print(importData.prefix?.name);
    }

    print("+++++++++++++++++++++");

    for (int i = 0; i < fields.length; ++i) {
      final field = fields[i];

      switch (field.name) {
        // データモジュールインターフェイス取得
        case 'iDataModule':
          if (!TypeCheck.isType(field)) {
            throw InvalidGenerationSourceError(
              '$className: iDataModuleの型がTypeでない。',
              element: element,
            );
          }
          interfaceName = field
              .computeConstantValue()
              ?.toTypeValue()
              .toString();

        case 'dataSources':
          final dataSources = field.computeConstantValue()?.toListValue();
          final record = dataSources?[0].toRecordValue();
          final first = record?.positional[0];
          final second = record?.positional[1];
          print(first?.toTypeValue()?.element?.library?.displayName);
          print(
            first?.toTypeValue()?.element?.library?.getExtendedDisplayName(),
          );
        // print(second?.toTypeValue()?.element?.library?.displayString());
        // print(record?.positional[0]);

        case 'repositories':
      }
    }

    return DataModuleTemplate(
      config: DataModuleGenerationConfig(
        moduleName: className,
        interfaceName: interfaceName,
      ),
    ).toString();
  }
}
