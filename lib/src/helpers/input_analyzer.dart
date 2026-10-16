import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:module_core_annotation/module_core_annotation.dart';

import 'check.dart';
import 'analyzed_dart_type.dart';
import 'library_analyzer.dart';

class InputAnalyzer {
  /// 解析対象のクラス名
  late final String className;

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

  InputAnalyzer({
    required LibraryElement library,
    required ConstantReader annotation,
  }) : _libraryAnalyzer = LibraryAnalyzer(library: library) {
    final libraryName = annotation.read('libraryName');
    if (libraryName.isString) {
      className = libraryName.stringValue;
    } else {
      className = _getFileNameAsCamelCase(library);
    }
    _checkAndGetDataSources(annotation.read('dataSources').mapValue);
    _checkAndGetRepositories(annotation.read('repositories').mapValue);
    _checkAndGetUsecases(annotation.read('usecases').setValue);
    _checkAndGetViewBuilders(annotation.read('viewBuilders').mapValue);
  }

  // データソースのリストを取得
  void _checkAndGetDataSources(Map<DartObject?, DartObject?> values) {
    for (final entry in values.entries) {
      final intf = entry.key?.toTypeValue();
      final impl = entry.value?.toTypeValue();

      if (intf == null || impl == null) {
        throw InvalidGenerationSourceError('$className: dataSourcesの型変換に失敗。');
      }

      final classIntf = intf.element;
      final classImpl = impl.element;
      if (classIntf is! ClassElement || classImpl is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$className: dataSourcesに登録される型はクラスでなければならない。',
        );
      }

      if (!Check.hasDefaultConstructor(classImpl)) {
        throw InvalidGenerationSourceError(
          '$className[${classImpl.name}]: データソースの実装クラスはデフォルトコンストラクタを保持していなければならない。',
        );
      }

      dataSources.add((
        getAnalyzedDartType(value: intf),
        getAnalyzedDartType(value: impl),
      ));
    }
  }

  // リポジトリのリストを取得
  void _checkAndGetRepositories(Map<DartObject?, DartObject?> values) {
    for (final entry in values.entries) {
      final intf = entry.key?.toTypeValue();
      final impl = entry.value?.toTypeValue();

      if (intf == null || impl == null) {
        throw InvalidGenerationSourceError('$className: repositoriesの型変換に失敗。');
      }

      final classIntf = intf.element;
      final classImpl = impl.element;
      if (classIntf is! ClassElement || classImpl is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$className: repositoriesに登録される型はクラスでなければならない。',
        );
      }

      if (!Check.isSubclassOf(classImpl, typeName: classIntf.name)) {
        throw InvalidGenerationSourceError(
          '$className[${classImpl.name}]: リポジトリの実装クラスが抽象クラスを継承していない。',
        );
      }

      if (!Check.isSubclassOf(classImpl, type: RepositoryAttachment)) {
        throw InvalidGenerationSourceError(
          '$className[${classImpl.name}]: リポジトリの実装クラスはRepositoryAttachmentを継承していなければならない。',
        );
      }

      if (!Check.hasDefaultConstructor(classImpl)) {
        throw InvalidGenerationSourceError(
          '$className[${classImpl.name}]: リポジトリの実装クラスはデフォルトコンストラクタを保持していなければならない。',
        );
      }

      repositories.add((
        getAnalyzedDartType(value: intf),
        getAnalyzedDartType(value: impl),
      ));
    }
  }

  // ユースケースのリストを取得
  void _checkAndGetUsecases(Set<DartObject> values) {
    for (final value in values) {
      final type = value.toTypeValue();
      if (type == null) {
        throw InvalidGenerationSourceError('$className: usecasesの解析に失敗。');
      }

      final classElement = type.element;
      if (classElement is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$className: usecasesに登録される型はクラスでなければならない。',
        );
      }
      if (!Check.isSubclassOf(classElement, type: UsecaseAttachment)) {
        throw InvalidGenerationSourceError(
          '$className[${classElement.name}]: ユースケースの実装クラスはUsecaseAttachmentを継承していなければならない。',
        );
      }
      if (!Check.hasDefaultConstructor(classElement)) {
        throw InvalidGenerationSourceError(
          '$className[${classElement.name}]: ユースケースの実装クラスはデフォルトコンストラクタを保持していなければならない。',
        );
      }
      usecases.add(getAnalyzedDartType(value: type));
    }
  }

  // ビュービルダーのリストを取得
  void _checkAndGetViewBuilders(Map<DartObject?, DartObject?> values) {
    for (final entry in values.entries) {
      final viewBuilderType = entry.key?.toTypeValue();
      final screenType = entry.value?.toTypeValue();

      if (viewBuilderType == null || screenType == null) {
        throw InvalidGenerationSourceError('$className: viewBuildersの型変換に失敗。');
      }

      final viewBuilderElement = viewBuilderType.element;
      if (viewBuilderElement is! ClassElement) {
        throw InvalidGenerationSourceError(
          '$className: viewBuildersのキーはクラスでなければならない。',
        );
      }
      if (!Check.isSubclassOf(
        viewBuilderElement,
        type: ViewBuilderAttachment,
        hasTypeArgs: true,
      )) {
        throw InvalidGenerationSourceError(
          '$className[${viewBuilderElement.name}]: viewBuilderはViewBuilderAttachmentを継承していなければならない。',
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

  static String _getFileNameAsCamelCase(LibraryElement lib) {
    // ファイル名のみ抽出
    final fileName = lib.identifier
        .replaceAll(RegExp(r'^.*/'), '')
        .replaceAll(RegExp(r'\.[^\.]*$'), '');

    // 不要な文字を削除しキャメルケース変換
    return fileName.split(RegExp(r'[^a-zA-Z0-9]+')).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join();
  }
}
