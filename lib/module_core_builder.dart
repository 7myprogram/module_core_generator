import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/module_core_generator.dart';

Builder moduleCoreBuilder(BuilderOptions options) => LibraryBuilder(
  ModuleCoreGenerator(),
  generatedExtension: '.module_core.dart',
);
