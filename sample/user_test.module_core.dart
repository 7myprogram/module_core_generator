// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'user_test.dart';

// **************************************************************************
// ModuleCoreGenerator
// **************************************************************************

UserTestProduct createUserTest() => UserTestProduct();

class UserTestProduct
    extends
        Core<
          $IUserTestDataModule,
          $IUserTestDomainModule,
          $IUserTestPresentationModule
        > {
  UserTestProduct()
    : super(
        data: _$UserTestDataModule(),
        domain: _$UserTestDomainModule(),
        presentation: _$UserTestPresentationModule(),
      );
}

abstract class $IUserTestDataModule {}

final class _$UserTestDataModule
    with DataModule
    implements $IUserTestDataModule {
  @override
  void registerDataSources(DataSourceCollection dataSourceCollection) {
    dataSourceCollection.register<i_data_source.DataSource1>(
      data_source_impl.DataSource1(),
    );
    dataSourceCollection.register<i_data_source.DataSource2>(
      data_source_impl.DataSource2(),
    );
    dataSourceCollection.register<i_data_source.DataSource3>(
      data_source_impl.DataSource3(),
    );
  }

  @override
  void registerRepositories(RepositoryCollection repositoryCollection) {
    repositoryCollection.register<i_repository.Repository1>(
      repository_impl.Repository1(),
    );
    repositoryCollection.register<i_repository.Repository2>(
      repository_impl.Repository2(),
    );
  }
}

abstract class $IUserTestDomainModule {}

final class _$UserTestDomainModule
    with DomainModule
    implements $IUserTestDomainModule {
  @override
  void registerUsecases(UsecaseCollection collection) {
    collection.register(Usecase1());
    collection.register(Usecase2());
    collection.register(Usecase3());
  }
}

abstract class $IUserTestPresentationModule {
  Screen1 buildScreenByViewBuilder1({dynamic args});
  Screen2 buildScreenByViewBuilder2({dynamic args});
  Screen3 buildScreenByViewBuilder3({dynamic args});
}

final class _$UserTestPresentationModule
    with PresentationModule
    implements $IUserTestPresentationModule {
  @override
  void registerViewBuilder(ViewBuilderCollection collection) {
    collection.register(ViewBuilder1());
    collection.register(ViewBuilder2());
    collection.register(ViewBuilder3());
  }

  @override
  Screen1 buildScreenByViewBuilder1({dynamic args}) {
    return getViewBuilder<ViewBuilder1>().buildScreen(args);
  }

  @override
  Screen2 buildScreenByViewBuilder2({dynamic args}) {
    return getViewBuilder<ViewBuilder2>().buildScreen(args);
  }

  @override
  Screen3 buildScreenByViewBuilder3({dynamic args}) {
    return getViewBuilder<ViewBuilder3>().buildScreen(args);
  }
}
