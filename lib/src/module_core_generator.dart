import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:module_core_annotation/module_core_annotation.dart';

import 'utils/check.dart';
import 'configs/entrypoint.dart';
import 'templates/entrypoint.dart';
import 'helpers/import_alias_map.dart';
import 'helpers/analyzed_dart_type.dart';

class ModuleCoreGenerator extends GeneratorForAnnotation<ModuleCore> {
  /// 解析対象のクラス名
  late final String _className;

  ///
  /// データモジュール関連の変数
  ///
  /// データソースリスト
  final List<(AnalyzedDartType, AnalyzedDartType)> _dataSources = [];

  /// リポジトリリスト
  final List<(AnalyzedDartType, AnalyzedDartType)> _repositories = [];

  ///
  /// ドメインモジュール関連の変数
  ///
  /// ユースケースリスト
  final List<AnalyzedDartType> _usecases = [];

  ///
  /// プレゼンテーションモジュール関連の変数
  ///
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

    // インポートファイルのエイリアスを取得
    ImportAliasMap().init(library);

    _analyze(element, library);

    final dataModuleBuffer = StringBuffer()
      ..writeln(
        AnalyzedDartType.getImportLines(
          library.uri.path.replaceAll(RegExp(r'/[^/]+$'), ''),
        ),
      )
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
    if (!Check.isListOfRecordTypeType(field)) {
      throw InvalidGenerationSourceError(
        '$_className: dataSourcesの型がList<(Type,Type)>でない。',
        element: field,
      );
    }

    final dataSources = field.computeConstantValue()?.toListValue();
    if (dataSources == null) {
      throw InvalidGenerationSourceError(
        '$_className: dataSourcesの内容の取得に失敗。',
        element: field,
      );
    }

    for (int i = 0; i < dataSources.length; ++i) {
      final record = dataSources[i].toRecordValue()?.positional;
      if (record == null || record.length < 2) {
        throw InvalidGenerationSourceError(
          '$_className: dataSourcesの解析に失敗。',
          element: field,
        );
      }
      if (!Check.hasDefaultConstructor(record[1].toTypeValue())) {
        throw InvalidGenerationSourceError(
          '$_className: データソースの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }
      final first = record[0].toTypeValue();
      final second = record[1].toTypeValue();
      if (first == null || second == null) {
        throw InvalidGenerationSourceError(
          '$_className: dataSourcesの型変換に失敗。',
          element: field,
        );
      }

      _dataSources.add((
        AnalyzedDartType(value: first),
        AnalyzedDartType(value: second),
      ));
    }
  }

  // リポジトリのリストを取得
  void _checkAndGetRepositories(FieldElement field) {
    if (!Check.isListOfRecordTypeType(field)) {
      throw InvalidGenerationSourceError(
        '$_className: repositoriesの型がList<(Type,Type)>でない。',
        element: field,
      );
    }

    final repositories = field.computeConstantValue()?.toListValue();
    if (repositories == null) {
      throw InvalidGenerationSourceError(
        '$_className: repositoriesの内容の取得に失敗。',
        element: field,
      );
    }

    for (int i = 0; i < repositories.length; ++i) {
      final record = repositories[i].toRecordValue()?.positional;
      if (record == null || record.length < 2) {
        throw InvalidGenerationSourceError(
          '$_className: repositoriesの解析に失敗。',
          element: field,
        );
      }
      if (!Check.hasDefaultConstructor(record[1].toTypeValue())) {
        throw InvalidGenerationSourceError(
          '$_className: リポジトリの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }
      final first = record[0].toTypeValue();
      final second = record[1].toTypeValue();
      if (first == null || second == null) {
        throw InvalidGenerationSourceError(
          '$_className: repositoriesの型変換に失敗。',
          element: field,
        );
      }
      _repositories.add((
        AnalyzedDartType(value: first),
        AnalyzedDartType(value: second),
      ));
    }
  }

  // ユースケースのリストを取得
  void _checkAndGetUsecases(FieldElement field) {
    if (!Check.isListOfType(field)) {
      throw InvalidGenerationSourceError(
        '$_className: usecasesの型がList<Type>でない。',
        element: field,
      );
    }

    final usecases = field.computeConstantValue()?.toListValue();
    if (usecases == null) {
      throw InvalidGenerationSourceError(
        '$_className: usecasesの内容の取得に失敗。',
        element: field,
      );
    }

    for (int i = 0; i < usecases.length; ++i) {
      final usecase = usecases[i].toTypeValue();
      if (usecase == null) {
        throw InvalidGenerationSourceError(
          '$_className: usecasesの解析に失敗。',
          element: field,
        );
      }
      if (!Check.hasDefaultConstructor(usecase)) {
        throw InvalidGenerationSourceError(
          '$_className: ユースケースの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }
      _usecases.add(AnalyzedDartType(value: usecase));
    }
  }

  // ビュービルダーのリストを取得
  void _checkAndGetViewBuilders(FieldElement field) {
    if (!Check.isListOfType(field)) {
      throw InvalidGenerationSourceError(
        '$_className: viewBuildersの型がList<Type>でない。',
        element: field,
      );
    }

    final viewBuilders = field.computeConstantValue()?.toListValue();
    if (viewBuilders == null) {
      throw InvalidGenerationSourceError(
        '$_className: viewBuildersの内容の取得に失敗。',
        element: field,
      );
    }

    for (int i = 0; i < viewBuilders.length; ++i) {
      final viewBuilder = viewBuilders[i].toTypeValue();
      if (viewBuilder == null) {
        throw InvalidGenerationSourceError(
          '$_className: viewBuildersの解析に失敗。',
          element: field,
        );
      }

      final element = viewBuilder.element;
      if (element is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$_className: viewBuilders内の型はクラスでなければならない。',
          element: field,
        );
      }
      if (!Check.isSubclassOf(element, 'ViewBuilderAttachment')) {
        throw InvalidGenerationSourceError(
          '$_className: viewBuilders内のクラスはViewBuilderAttachmentを継承していなければならない。',
          element: field,
        );
      }

      _viewBuilderAndScreens.add((
        AnalyzedDartType(value: viewBuilder),
        AnalyzedDartType(
          value: element.allSupertypes
              .where((elem) {
                return elem.element.name == 'ViewBuilderAttachment';
              })
              .first
              .typeArguments[0],
        ),
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
