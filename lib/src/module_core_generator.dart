import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:module_core_annotation/module_core_annotation.dart';

import 'utils/entrypoint.dart';
import 'configs/entrypoint.dart';
import 'templates/entrypoint.dart';

class ModuleCoreGenerator extends GeneratorForAnnotation<ModuleCore> {
  /// インポートファイルのエイリアスマップ
  late final _ImportAliasMap _importAliasMap;

  /// 解析対象のクラス名
  late final String _className;

  ///
  /// データモジュール関連の変数
  ///
  /// データソースリスト
  final List<List<DartObject>> _dataSources = [];

  /// リポジトリリスト
  final List<List<DartObject>> _repositories = [];

  ///
  /// ドメインモジュール関連の変数
  ///
  /// ユースケースリスト
  final List<DartType> _usecases = [];

  ///
  /// プレゼンテーションモジュール関連の変数
  ///
  /// ビュービルダーリスト
  final List<DartType> _viewBuilders = [];

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

    _analyze(element, library);

    // インポートファイルのエイリアスを取得
    _importAliasMap = _ImportAliasMap(library);

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
      if (record == null) {
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
      _dataSources.add(record);
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
      if (record == null) {
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
      _repositories.add(record);
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
      _usecases.add(usecase);
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

      _viewBuilders.add(viewBuilder);
    }
  }

  // コアの出力
  String _writeCore() {
    return CoreTemplate(config: CoreGenerationConfig(moduleName: _className))
        .toString();
  }

  // データモジュールの出力
  String _writeDataModule() {
    List<(String, String)> dataSourceNames = [];
    for (final dataSource in _dataSources) {
      final names = _getNameRecord(dataSource);
      if (names == null) {
        throw InvalidGenerationSourceError('$_className: データソースの名前取得に失敗。');
      }
      dataSourceNames.add(names);
    }

    List<(String, String)> repositoryNames = [];
    for (final repository in _repositories) {
      final names = _getNameRecord(repository);
      if (names == null) {
        throw InvalidGenerationSourceError('$_className: リポジトリの名前取得に失敗。');
      }
      repositoryNames.add(names);
    }

    return DataModuleTemplate(
      config: DataModuleGenerationConfig(
        moduleName: _className,
        dataSourceNames: dataSourceNames,
        repositoryNames: repositoryNames,
      ),
    ).toString();
  }

  // ドメインモジュールの出力
  String _writeDomainModule() {
    List<String> usecaseNames = [];
    for (final usecase in _usecases) {
      usecaseNames.add(_getClassNameWithAlias(usecase));
    }

    return DomainModuleTemplate(
      config: DomainModuleGenerationConfig(
        moduleName: _className,
        usecaseNames: usecaseNames,
      ),
    ).toString();
  }

  // プレゼンテーションモジュールの出力
  String _writePresentationModule() {
    List<(String, String)> viewBuilderNames = [];

    for (final viewBuilder in _viewBuilders) {
      final element = viewBuilder.element as ClassElement;
      viewBuilderNames.add((
        _getClassNameWithAlias(viewBuilder),
        _getClassNameWithAlias(
          element.allSupertypes
              .where((elem) {
                return elem.element.name == 'ViewBuilderAttachment';
              })
              .first
              .typeArguments[0],
        ),
      ));
    }

    return PresentationModuleTemplate(
      config: PresentationModuleGenerationConfig(
        moduleName: _className,
        viewBuilders: viewBuilderNames,
      ),
    ).toString();
  }

  // インターフェイスと実装クラスの名前セットの配列を返す。
  (String, String)? _getNameRecord(List<DartObject> objectList) {
    final iType = objectList[0].toTypeValue();
    final implType = objectList[1].toTypeValue();

    if (iType == null || implType == null) {
      return null;
    }

    return (_getClassNameWithAlias(iType), _getClassNameWithAlias(implType));
  }

  // エイリアス付きでクラス名を返す
  String _getClassNameWithAlias(DartType type) {
    final alias = _importAliasMap.getAliasByType(type);
    return "${alias == null ? "" : "$alias."}${type.toString()}";
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

  String? getAliasByType(DartType? object) {
    final key = object?.element?.library?.displayString().replaceAll(
      RegExp(r'^.* '),
      "",
    );

    if (key == null) {
      return null;
    }
    return map[key];
  }
}
