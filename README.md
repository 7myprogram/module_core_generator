# module_core_generator

## 概要

[module_core](https://github.com/7myprogram/module_core) で使用するモジュールおよびコアのコード生成を行うパッケージです。

libraryに付与した `@ModuleCore` アノテーションの情報をもとに、データソース、リポジトリ、ユースケース、ビュービルダーの登録処理を生成します。

## コード生成

`sample` ディレクトリに実装例があります。

### 1. アノテーションを付与する

モジュールを定義するDartファイルのlibraryに `@ModuleCore` アノテーションを付与します。

各パラメータには、モジュール名や依存性注入に使用する型の対応関係、登録するユースケースなどを指定します。

| パラメータ | 説明 |
|---|---|
| `libraryName` | 生成するモジュール名を指定します。省略時はファイル名をもとに自動設定されます。 |
| `dataSources` | データソースのインターフェースと実装を対応付けます。キーにインターフェース、値に実装の型を指定します。 |
| `repositories` | リポジトリのインターフェースと実装を対応付けます。キーにインターフェース、値に実装の型を指定します。 |
| `usecases` | 登録するユースケースの型を指定します。 |
| `viewBuilders` | ビュービルダーと生成対象のスクリーンの型を対応付けます。キーにビュービルダー、値にビュービルダーが生成するスクリーンの型を指定します。 |

以下は記述例です。

```dart
@ModuleCore(
  // モジュール名
  libraryName: 'SomeModule',

  // データソースの登録と依存性注入
  dataSources: {
    ISomeDataSource1: SomeDataSource1Impl,
    ISomeDataSource2: SomeDataSource2Impl,
    ISomeDataSource3: SomeDataSource3Impl,
  },

  // リポジトリの登録と依存性注入
  repositories: {
    ISomeRepository1: Repository1Impl,
    ISomeRepository2: Repository2Impl,
  },

  // ユースケースの登録
  usecases: {
    SomeUsecase1,
    SomeUsecase2,
    SomeUsecase3,
  },

  // ビュービルダーの登録
  viewBuilders: {
    SomeViewBuilder1: SomeScreen1,
    SomeViewBuilder2: SomeScreen2,
    SomeViewBuilder3: SomeScreen3,
  },
)
library;

import '...';
import '...';
import '...';

part 'xxx.module_core.dart';
```

`import` には、アノテーションで指定する各型を定義したライブラリを記述します。

`part` には、生成されるDartファイルを指定します。ファイル名は実際の生成規則に合わせてください。

### 2. コードを生成する

プロジェクトのルートディレクトリで、次のコマンドを実行します。

```bash
dart run build_runner build
```

既存の生成ファイルとの競合が発生する場合は、生成先を確認したうえで、次のコマンドを使用してください。

```bash
dart run build_runner build --delete-conflicting-outputs
```

生成されたファイルには、アノテーションで指定した情報に基づくモジュールおよびコアの実装が出力されます。
