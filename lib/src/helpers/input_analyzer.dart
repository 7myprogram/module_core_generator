import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:module_core_annotation/module_core_annotation.dart';

import 'check.dart';
import 'analyzed_dart_type.dart';
import 'library_analyzer.dart';

class InputAnalyzer {
  /// 解析対象のクラスエレメント
  final ClassElement _element;

  /// 解析対象のクラス名
  final String className;

  /// 解析対象のライブラリエレメント
  final LibraryAnalyzer _libraryAnalyzer;

  /// データソースリスト
  final List<(AnalyzedDartType, AnalyzedDartType)> dataSources = [];

  /// リポジトリリスト
  final List<(AnalyzedDartType, AnalyzedDartType)> repositories = [];

  /// ユースケースリスト
  final List<AnalyzedDartType> usecases = [];

  /// ビュービルダー/Screenリスト
  final List<(AnalyzedDartType, AnalyzedDartType)> viewBuilderAndScreens = [];

  InputAnalyzer({required this._element, required LibraryElement library})
    : className = _element.displayName,
      _libraryAnalyzer = LibraryAnalyzer(library: library);

  void analyze() {
    final fields = _element.fields;
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
    if (!Check.checkType(field, Map<Type, Type>)) {
      throw InvalidGenerationSourceError(
        '$className: dataSourcesの型がMap<Type,Type>でない。',
        element: field,
      );
    }

    final dataSources = field.computeConstantValue()?.toMapValue();
    if (dataSources == null) {
      throw InvalidGenerationSourceError(
        '$className: dataSourcesの内容の取得に失敗。',
        element: field,
      );
    }

    for (final dataSource in dataSources.entries) {
      final intf = dataSource.key?.toTypeValue();
      final impl = dataSource.value?.toTypeValue();

      if (intf == null || impl == null) {
        throw InvalidGenerationSourceError(
          '$className: dataSourcesの型変換に失敗。',
          element: field,
        );
      }

      final classIntf = intf.element;
      final classImpl = impl.element;
      if (classIntf is! ClassElement || classImpl is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$className: dataSourcesに登録される型はクラスでなければならない。',
          element: field,
        );
      }

      if (!Check.hasDefaultConstructor(classImpl)) {
        throw InvalidGenerationSourceError(
          '$className[${classImpl.name}]: データソースの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }

      this.dataSources.add((
        getAnalyzedDartType(value: intf),
        getAnalyzedDartType(value: impl),
      ));
    }
  }

  // リポジトリのリストを取得
  void _checkAndGetRepositories(FieldElement field) {
    if (!Check.checkType(field, Map<Type, Type>)) {
      throw InvalidGenerationSourceError(
        '$className: repositoriesの型がList<(Type,Type)>でない。',
        element: field,
      );
    }

    final repositories = field.computeConstantValue()?.toMapValue();
    if (repositories == null) {
      throw InvalidGenerationSourceError(
        '$className: repositoriesの内容の取得に失敗。',
        element: field,
      );
    }

    for (final repository in repositories.entries) {
      final intf = repository.key?.toTypeValue();
      final impl = repository.value?.toTypeValue();

      if (intf == null || impl == null) {
        throw InvalidGenerationSourceError(
          '$className: repositoriesの型変換に失敗。',
          element: field,
        );
      }

      final classIntf = intf.element;
      final classImpl = impl.element;
      if (classIntf is! ClassElement || classImpl is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$className: repositoriesに登録される型はクラスでなければならない。',
          element: field,
        );
      }

      if (!Check.isSubclassOf(classImpl, typeName: classIntf.name)) {
        throw InvalidGenerationSourceError(
          '$className[${classImpl.name}]: リポジトリの実装クラスが抽象クラスを継承していない。',
          element: field,
        );
      }

      if (!Check.isSubclassOf(classImpl, type: RepositoryAttachment)) {
        throw InvalidGenerationSourceError(
          '$className[${classImpl.name}]: リポジトリの実装クラスはRepositoryAttachmentを継承していなければならない。',
          element: field,
        );
      }

      if (!Check.hasDefaultConstructor(classImpl)) {
        throw InvalidGenerationSourceError(
          '$className[${classImpl.name}]: リポジトリの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }

      this.repositories.add((
        getAnalyzedDartType(value: intf),
        getAnalyzedDartType(value: impl),
      ));
    }
  }

  // ユースケースのリストを取得
  void _checkAndGetUsecases(FieldElement field) {
    if (!Check.checkType(field, Set<Type>)) {
      throw InvalidGenerationSourceError(
        '$className: Set<Type>でない。',
        element: field,
      );
    }

    final usecases = field.computeConstantValue()?.toSetValue();
    if (usecases == null) {
      throw InvalidGenerationSourceError(
        '$className: usecasesの内容の取得に失敗。',
        element: field,
      );
    }

    for (final usecase in usecases) {
      final type = usecase.toTypeValue();
      if (type == null) {
        throw InvalidGenerationSourceError(
          '$className: usecasesの解析に失敗。',
          element: field,
        );
      }

      final classElement = type.element;
      if (classElement is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$className: usecasesに登録される型はクラスでなければならない。',
          element: field,
        );
      }
      if (!Check.isSubclassOf(classElement, type: UsecaseAttachment)) {
        throw InvalidGenerationSourceError(
          '$className[${classElement.name}]: ユースケースの実装クラスはUsecaseAttachmentを継承していなければならない。',
          element: field,
        );
      }
      if (!Check.hasDefaultConstructor(classElement)) {
        throw InvalidGenerationSourceError(
          '$className[${classElement.name}]: ユースケースの実装クラスはデフォルトコンストラクタを保持していなければならない。',
          element: field,
        );
      }
      this.usecases.add(getAnalyzedDartType(value: type));
    }
  }

  // ビュービルダーのリストを取得
  void _checkAndGetViewBuilders(FieldElement field) {
    if (!Check.checkType(field, Map<Type, Type>)) {
      throw InvalidGenerationSourceError(
        '$className: viewBuildersの型がMap<Type,Type>でない。',
        element: field,
      );
    }

    final viewBuilders = field.computeConstantValue()?.toMapValue();
    if (viewBuilders == null) {
      throw InvalidGenerationSourceError(
        '$className: viewBuildersの内容の取得に失敗。',
        element: field,
      );
    }

    for (final entry in viewBuilders.entries) {
      final viewBuilderType = entry.key?.toTypeValue();
      final screenType = entry.value?.toTypeValue();

      if (viewBuilderType == null || screenType == null) {
        throw InvalidGenerationSourceError(
          '$className: viewBuildersの型変換に失敗。',
          element: field,
        );
      }

      final viewBuilderElement = viewBuilderType.element;
      if (viewBuilderElement is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$className: viewBuildersのキーはクラスでなければならない。',
          element: field,
        );
      }
      if (!Check.isSubclassOf(
        viewBuilderElement,
        type: ViewBuilderAttachment,
        hasTypeArgs: true,
      )) {
        throw InvalidGenerationSourceError(
          '$className[${viewBuilderElement.name}]: viewBuilderはViewBuilderAttachmentを継承していなければならない。',
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
          '$className[${viewBuilderElement.name}]: ViewBuilderAttachmentの型引数とScreenは同じ型でなければならない。',
          element: field,
        );
      }

      viewBuilderAndScreens.add((
        getAnalyzedDartType(value: viewBuilderType),
        getAnalyzedDartType(value: screenType),
      ));
    }
  }

  AnalyzedDartType getAnalyzedDartType({required DartType value}) {
    return AnalyzedDartType(
      value: value,
      alias: _libraryAnalyzer.getAlias(value),
    );
  }
}
