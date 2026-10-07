import 'package:module_core_annotation/module_core_annotation.dart';
import 'package:module_core_generator/src/source_for_test/data_source4_impl.dart';
import 'package:module_core_generator/src/source_for_test/i_data_source4.dart';

import '../usecase4.dart';
import 'data_sources/interfaces/entrypoint.dart' as i_data_source;
import 'data_sources/implementations/entrypoint.dart' as data_source_impl;
import 'repositories/interfaces/entrypoint.dart' as i_repository;
import 'repositories/implementations/entrypoint.dart' as repository_impl;
import 'usecases/entrypoint.dart';
import 'view_builders/entrypoint.dart';

part 'user.module_core.dart';

@ModuleCore()
class UserModule {
  /// データ層設定
  static const dataSources = [
    (i_data_source.DataSource1, data_source_impl.DataSource1),
    (i_data_source.DataSource2, data_source_impl.DataSource2),
    (i_data_source.DataSource3, data_source_impl.DataSource3),
    (IDataSource4, DataSource4),
  ];
  static const repositories = [
    (i_repository.Repository1, repository_impl.Repository1),
    (i_repository.Repository2, repository_impl.Repository2),
  ];

  /// ドメイン層設定
  static const usecases = [Usecase1, Usecase2, Usecase3, Usecase4];

  /// プレゼンテーション層設定
  static const viewBuilders = [ViewBuilder1, ViewBuilder2, ViewBuilder3];
}
