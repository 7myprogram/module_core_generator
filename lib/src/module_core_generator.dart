import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:module_core_annotation/module_core_annotation.dart';

import 'utils/check.dart';
import 'configs/entrypoint.dart';
import 'templates/entrypoint.dart';
import 'helpers/analyzed_dart_type.dart';
import 'helpers/library_analyzer.dart';

class ModuleCoreGenerator extends GeneratorForAnnotation<ModuleCore> {
  /// 解析対象のクラス名
  late final String _className;

  /// データソースリスト
  final List<(AnalyzedDartType, AnalyzedDartType)> _dataSources = [];

  /// リポジトリリスト
  final List<(AnalyzedDartType, AnalyzedDartType)> _repositories = [];

  /// ユースケースリスト
  final List<AnalyzedDartType> _usecases = [];

  /// ビュービルダー/Screenリスト
  final List<(AnalyzedDartType, AnalyzedDartType)> _viewBuilderAndScreens = [];

  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@ModuleCoreクラス以外の処理不可 ${element.name}',
        element: element,
      );
    }

    _className = element.displayName;

    final library = await buildStep.resolver.libraryFor(buildStep.inputId);

    LibraryAnalyzer().init(library);

    _analyze(element, library);

    final dataModuleBuffer = StringBuffer()
      ..writeln(_writeCore())
      ..writeln(_writeDataModule())
      ..writeln(_writeDomainModule())
      ..writeln(_writePresentationModule());

    return dataModuleBuffer.toString();
  }

  void _analyze(ClassElement element, LibraryElement library) {
    final fields = element.fields;
    for (final field in fields) {
      switch (field.name) {
        // データソース取得
        case 'dataSources':
          _checkAndGetDataSources(field);

        // リポジトリ取得
        case 'repositories':
          _checkAndGetRepositories(field);

        // ユースケース取得
        case 'usecases':
          _checkAndGetUsecases(field);

        // ビュービルダー取得
        case 'viewBuilders':
          _checkAndGetViewBuilders(field);
      }
    }
  }

  // データソースのリストを取得
  void _checkAndGetDataSources(FieldElement field) {
    if (!Check.isTypeTypeMap(field)) {
      throw InvalidGenerationSourceError(
        '$_className: dataSourcesの型がMap<Type,Type>でない。',
        element: field,
      );
    }

    final dataSources = field.computeConstantValue()?.toMapValue();
    if (dataSources == null) {
      throw InvalidGenerationSourceError(
        '$_className: dataSourcesの内容の取得に失敗。',
        element: field,
      );
    }

    for (final dataSource in dataSources.entries) {
      final intf = dataSource.key?.toTypeValue();
      final impl = dataSource.value?.toTypeValue();

      if (intf == null || impl == null) {
        throw InvalidGenerationSourceError(
          '$_className: dataSourcesの型変換に失敗。',
          element: field,
        );
      }

      if (!Check.hasDefaultConstructor(impl)) {
        throw InvalidGenerationSourceError(
          '$_className: データソースの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }

      _dataSources.add((
        AnalyzedDartType(value: intf),
        AnalyzedDartType(value: impl),
      ));
    }
  }

  // リポジトリのリストを取得
  void _checkAndGetRepositories(FieldElement field) {
    if (!Check.isTypeTypeMap(field)) {
      throw InvalidGenerationSourceError(
        '$_className: repositoriesの型がList<(Type,Type)>でない。',
        element: field,
      );
    }

    final repositories = field.computeConstantValue()?.toMapValue();
    if (repositories == null) {
      throw InvalidGenerationSourceError(
        '$_className: repositoriesの内容の取得に失敗。',
        element: field,
      );
    }

    for (final repository in repositories.entries) {
      final intf = repository.key?.toTypeValue();
      final impl = repository.value?.toTypeValue();

      if (intf == null || impl == null) {
        throw InvalidGenerationSourceError(
          '$_className: repositoriesの型変換に失敗。',
          element: field,
        );
      }

      if (!Check.hasDefaultConstructor(impl)) {
        throw InvalidGenerationSourceError(
          '$_className: リポジトリの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }

      _repositories.add((
        AnalyzedDartType(value: intf),
        AnalyzedDartType(value: impl),
      ));
    }
  }

  // ユースケースのリストを取得
  void _checkAndGetUsecases(FieldElement field) {
    if (!Check.isSetOfType(field)) {
      throw InvalidGenerationSourceError(
        '$_className: Set<Type>でない。',
        element: field,
      );
    }

    final usecases = field.computeConstantValue()?.toSetValue();
    if (usecases == null) {
      throw InvalidGenerationSourceError(
        '$_className: usecasesの内容の取得に失敗。',
        element: field,
      );
    }

    for (final usecase in usecases) {
      final uType = usecase.toTypeValue();
      if (uType == null) {
        throw InvalidGenerationSourceError(
          '$_className: usecasesの解析に失敗。',
          element: field,
        );
      }
      if (!Check.hasDefaultConstructor(uType)) {
        throw InvalidGenerationSourceError(
          '$_className: ユースケースの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }
      _usecases.add(AnalyzedDartType(value: uType));
    }
  }

  // ビュービルダーのリストを取得
  void _checkAndGetViewBuilders(FieldElement field) {
    if (!Check.isTypeTypeMap(field)) {
      throw InvalidGenerationSourceError(
        '$_className: viewBuildersの型がMap<Type,Type>でない。',
        element: field,
      );
    }

    final viewBuilders = field.computeConstantValue()?.toMapValue();
    if (viewBuilders == null) {
      throw InvalidGenerationSourceError(
        '$_className: viewBuildersの内容の取得に失敗。',
        element: field,
      );
    }

    for (final entry in viewBuilders.entries) {
      final viewBuilderType = entry.key?.toTypeValue();
      final screenType = entry.value?.toTypeValue();

      if (viewBuilderType == null || screenType == null) {
        throw InvalidGenerationSourceError(
          '$_className: viewBuildersの型変換に失敗。',
          element: field,
        );
      }

      final viewBuilderElement = viewBuilderType.element;
      if (viewBuilderElement is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$_className: viewBuildersのキーはクラスでなければならない。',
          element: field,
        );
      }
      if (!Check.isSubclassOf(viewBuilderElement, 'ViewBuilderAttachment')) {
        throw InvalidGenerationSourceError(
          '$_className: viewBuilderはViewBuilderAttachmentを継承していなければならない。',
          element: field,
        );
      }

      final viewBuilderTypeArgument = viewBuilderElement.allSupertypes
          .where((elem) {
            return elem.element.name == 'ViewBuilderAttachment';
          })
          .first
          .typeArguments[0];
      if (screenType.toString() != viewBuilderTypeArgument.toString()) {
        throw InvalidGenerationSourceError(
          '$_className: ViewBuilderAttachmentの型引数とScreenは同じ型でなければならない。',
          element: field,
        );
      }

      _viewBuilderAndScreens.add((
        AnalyzedDartType(value: viewBuilderType),
        AnalyzedDartType(value: screenType),
      ));
    }
  }

  // コアの出力
  String _writeCore() {
    return CoreTemplate(config: CoreGenerationConfig(moduleName: _className))
        .toString();
  }

  // データモジュールの出力
  String _writeDataModule() {
    return DataModuleTemplate(
      config: DataModuleGenerationConfig(
        moduleName: _className,
        dataSources: _dataSources,
        repositories: _repositories,
      ),
    ).toString();
  }

  // ドメインモジュールの出力
  String _writeDomainModule() {
    return DomainModuleTemplate(
      config: DomainModuleGenerationConfig(
        moduleName: _className,
        usecases: _usecases,
      ),
    ).toString();
  }

  // プレゼンテーションモジュールの出力
  String _writePresentationModule() {
    return PresentationModuleTemplate(
      config: PresentationModuleGenerationConfig(
        moduleName: _className,
        viewBuilderAndScreens: _viewBuilderAndScreens,
      ),
    ).toString();
  }
}
