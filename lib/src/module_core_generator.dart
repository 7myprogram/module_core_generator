import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:module_core_annotation/module_core_annotation.dart';

import 'configs/entrypoint.dart';
import 'templates/entrypoint.dart';
import 'helpers/input_analyzer.dart';
import 'helpers/analyzed_dart_type.dart';

class ModuleCoreGenerator extends GeneratorForAnnotation<ModuleCore> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! LibraryElement) {
      throw InvalidGenerationSourceError(
        '@ModuleCoreアノテーションはlibraryに付与。 ${element.name}',
        element: element,
      );
    }

    final inputAnalyzer = InputAnalyzer(library: element);

    final dataModuleBuffer = StringBuffer()
      ..writeln(_writeCore(className: inputAnalyzer.className))
      ..writeln(
        _writeDataModule(
          className: inputAnalyzer.className,
          dataSources: inputAnalyzer.dataSources,
          repositories: inputAnalyzer.repositories,
        ),
      )
      ..writeln(
        _writeDomainModule(
          className: inputAnalyzer.className,
          usecases: inputAnalyzer.usecases,
        ),
      )
      ..writeln(
        _writePresentationModule(
          className: inputAnalyzer.className,
          viewBuilderAndScreens: inputAnalyzer.viewBuilderAndScreens,
        ),
      );

    return dataModuleBuffer.toString();
  }

  // コアの出力
  String _writeCore({required String className}) {
    return CoreTemplate(config: CoreGenerationConfig(moduleName: className))
        .toString();
  }

  // データモジュールの出力
  String _writeDataModule({
    required String className,
    required List<(AnalyzedDartType, AnalyzedDartType)> dataSources,
    required List<(AnalyzedDartType, AnalyzedDartType)> repositories,
  }) {
    return DataModuleTemplate(
      config: DataModuleGenerationConfig(
        moduleName: className,
        dataSources: dataSources,
        repositories: repositories,
      ),
    ).toString();
  }

  // ドメインモジュールの出力 List<AnalyzedDartType>
  String _writeDomainModule({
    required String className,
    required List<AnalyzedDartType> usecases,
  }) {
    return DomainModuleTemplate(
      config: DomainModuleGenerationConfig(
        moduleName: className,
        usecases: usecases,
      ),
    ).toString();
  }

  // プレゼンテーションモジュールの出力
  String _writePresentationModule({
    required String className,
    required List<(AnalyzedDartType, AnalyzedDartType)> viewBuilderAndScreens,
  }) {
    return PresentationModuleTemplate(
      config: PresentationModuleGenerationConfig(
        moduleName: className,
        viewBuilderAndScreens: viewBuilderAndScreens,
      ),
    ).toString();
  }
}
