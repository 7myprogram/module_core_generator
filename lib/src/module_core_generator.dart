import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:module_core_annotation/module_core_annotation.dart';

import 'utils/entrypoint.dart';
import 'configs/entrypoint.dart';
import 'templates/entrypoint.dart';

class ModuleCoreGenerator extends GeneratorForAnnotation<ModuleCore> {
  late final _ImportAliasMap _importAliasMap;

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

    // インポートファイルのエイリアスを取得
    _importAliasMap = _ImportAliasMap(library);

    final dataModuleBuffer = StringBuffer()
      ..writeln(_writeDataModule(element, library));

    return dataModuleBuffer.toString();
  }

  String _writeDataModule(ClassElement element, LibraryElement library) {
    final className = element.displayName;
    final fields = element.fields;

    String? interfaceName;
    final List<(String, String)> dataSourceNames = [];
    final List<(String, String)> repositoryNames = [];
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
          if (!TypeCheck.isListOfRecordTypeType(field)) {
            throw InvalidGenerationSourceError(
              '$className: dataSourcesの型がList<(Type,Type)>でない。',
              element: element,
            );
          }

          final dataSources = field.computeConstantValue()?.toListValue();
          if (dataSources == null) {
            throw InvalidGenerationSourceError(
              '$className: dataSourcesの内容の取得に失敗。',
              element: element,
            );
          }

          for (int i = 0; i < dataSources.length; ++i) {
            final names = _getNameRecord(dataSources[i]);
            if (names == null) {
              throw InvalidGenerationSourceError(
                '$className: dataSourcesの要素の解析に失敗。',
                element: element,
              );
            }
            dataSourceNames.add(names);
          }

        case 'repositories':
          if (!TypeCheck.isListOfRecordTypeType(field)) {
            throw InvalidGenerationSourceError(
              '$className: repositoriesの型がList<(Type,Type)>でない。',
              element: element,
            );
          }

          final repositories = field.computeConstantValue()?.toListValue();
          if (repositories == null) {
            throw InvalidGenerationSourceError(
              '$className: repositoriesの内容の取得に失敗。',
              element: element,
            );
          }

          for (int i = 0; i < repositories.length; ++i) {
            final names = _getNameRecord(repositories[i]);
            if (names == null) {
              throw InvalidGenerationSourceError(
                '$className: repositoriesの要素の解析に失敗。',
                element: element,
              );
            }
            repositoryNames.add(names);
          }
      }
    }

    return DataModuleTemplate(
      config: DataModuleGenerationConfig(
        moduleName: className,
        interfaceName: interfaceName,
        dataSourceNames: dataSourceNames,
        repositoryNames: repositoryNames,
      ),
    ).toString();
  }

  (String, String)? _getNameRecord(DartObject object) {
    final record = object.toRecordValue();

    final first = record?.positional[0];
    final second = record?.positional[1];

    if (first == null || second == null) {
      return null;
    }

    final interfaceAlias = _importAliasMap.getAlias(first);
    final interface =
        "${interfaceAlias == null ? "" : "$interfaceAlias."}${first.toTypeValue().toString()}";
    final implAlias = _importAliasMap.getAlias(second);
    final impl =
        "${implAlias == null ? "" : "$implAlias."}${second.toTypeValue().toString()}";

    return (interface, impl);
  }
}

class _ImportAliasMap {
  final Map<String, String?> map = {};

  _ImportAliasMap(LibraryElement libraryElement) {
    final libraryImports = libraryElement.firstFragment.libraryImports;
    for (int i = 0; i < libraryImports.length; ++i) {
      final importData = libraryImports[i];
      final alias = importData.prefix?.name;

      if (alias == null) {
        continue;
      }

      map[importData.toString().replaceAll(RegExp(r'^.* '), "")] = alias;
    }
  }

  String? getAlias(DartObject? object) {
    final key = object
        ?.toTypeValue()
        ?.element
        ?.library
        ?.displayString()
        .replaceAll(RegExp(r'^.* '), "");

    if (key == null) {
      return null;
    }
    return map[key];
  }
}
