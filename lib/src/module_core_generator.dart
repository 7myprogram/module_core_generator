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
  /// データモジュールに設定するインターフェイス名
  String? _dataModuleInterfaceName;

  /// データソースリスト
  final List<List<DartObject>> _dataSources = [];

  /// リポジトリリスト
  final List<List<DartObject>> _repositories = [];

  ///
  /// ドメインモジュール関連の変数
  ///
  /// ドメインモジュールに設定するインターフェイス名
  String? _domainModuleInterfaceName;

  /// ユースケースリスト
  final List<DartType> _usecases = [];

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
      ..writeln(_writeDataModule())
      ..writeln(_writeDomainModule());

    return dataModuleBuffer.toString();
  }

  void _analyze(ClassElement element, LibraryElement library) {
    final fields = element.fields;
    for (final field in fields) {
      switch (field.name) {
        // データモジュールインターフェイス名取得
        case 'iData':
          _checkAndGetDataModuleInterfaceName(field);

        // データソース取得
        case 'dataSources':
          _checkAndGetDataSources(field);

        // リポジトリ取得
        case 'repositories':
          _checkAndGetRepositories(field);

        // ドメインモジュールインターフェイス名取得
        case 'iDomain':
          _checkAndGetDomainModuleInterfaceName(field);

        // ユースケース取得
        case 'usecases':
          _checkAndGetUsecases(field);
      }
    }
  }

  // データモジュールのインターフェイス名を取得
  void _checkAndGetDataModuleInterfaceName(FieldElement field) {
    if (!Check.isType(field)) {
      throw InvalidGenerationSourceError(
        '$_className: iDataの型がTypeでない。',
        element: field,
      );
    }

    _dataModuleInterfaceName = field
        .computeConstantValue()
        ?.toTypeValue()
        .toString();
  }

  // ドメインモジュールのインターフェイス名を取得
  void _checkAndGetDomainModuleInterfaceName(FieldElement field) {
    if (!Check.isType(field)) {
      throw InvalidGenerationSourceError(
        '$_className: iDomainの型がTypeでない。',
        element: field,
      );
    }

    _domainModuleInterfaceName = field
        .computeConstantValue()
        ?.toTypeValue()
        .toString();
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
        interfaceName: _dataModuleInterfaceName,
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
        interfaceName: _dataModuleInterfaceName,
        usecaseNames: usecaseNames,
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
