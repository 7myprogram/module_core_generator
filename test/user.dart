import 'package:module_core_annotation/module_core_annotation.dart';
import 'package:module_core/module_core.dart';

import 'data_sources/interfaces/data_source1.dart' as i_data_source;
import 'data_sources/interfaces/data_source2.dart' as i_data_source;
import 'data_sources/implementations/data_source1.dart' as data_source_impl;
import 'data_sources/implementations/data_source2.dart' as data_source_impl;
import 'repositories/interfaces/repository1.dart' as i_repository;
import 'repositories/interfaces/repository2.dart' as i_repository;
import 'repositories/implementations/repository1.dart' as repository_impl;
import 'repositories/implementations/repository2.dart' as repository_impl;
import 'usecases/usecase1.dart' as usecase;
import 'usecases/usecase2.dart';
import 'usecases/usecase3.dart';
import 'view_builders/view_builder1.dart' as view_builder;
import 'view_builders/view_builder2.dart';
import 'view_builders/view_builder3.dart';
part 'user.module_core.dart';

@ModuleCore()
class UserModule extends $UserModuleCore {
  /// データ層設定
  static const dataSources = [
    (i_data_source.DataSource1, data_source_impl.DataSource1),
    (i_data_source.DataSource2, data_source_impl.DataSource2),
  ];
  static const repositories = [
    (i_repository.Repository1, repository_impl.Repository1),
    (i_repository.Repository2, repository_impl.Repository2),
  ];

  /// ドメイン層設定
  static const usecases = [usecase.Usecase1, Usecase2, Usecase3];

  /// プレゼンテーション層設定
  static const viewBuilders = [
    view_builder.ViewBuilder1,
    ViewBuilder2,
    ViewBuilder3,
  ];
}
