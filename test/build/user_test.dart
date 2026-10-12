@ModuleCore(
  dataSources: {
    i_data_source.DataSource1: data_source_impl.DataSource1,
    i_data_source.DataSource2: data_source_impl.DataSource2,
    i_data_source.DataSource3: data_source_impl.DataSource3,
  },
  repositories: {
    i_repository.Repository1: repository_impl.Repository1,
    i_repository.Repository2: repository_impl.Repository2,
  },
  usecases: {Usecase1, Usecase2, Usecase3, Usecase4},
  viewBuilders: {
    ViewBuilder1: Screen1,
    ViewBuilder2: Screen2,
    ViewBuilder3: Screen3,
  },
)
library;

import 'package:module_core_annotation/module_core_annotation.dart';

import '../usecase4.dart';
import 'data_sources/interfaces/entrypoint.dart' as i_data_source;
import 'data_sources/implementations/entrypoint.dart' as data_source_impl;
import 'repositories/interfaces/entrypoint.dart' as i_repository;
import 'repositories/implementations/entrypoint.dart' as repository_impl;
import 'usecases/entrypoint.dart';
import 'view_builders/entrypoint.dart';

part 'user_test.module_core.dart';
