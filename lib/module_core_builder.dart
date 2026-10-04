import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/module_core_generator.dart';

Builder moduleCoreBuilder(BuilderOptions options) =>
    PartBuilder([ModuleCoreGenerator()], '.module_core.dart');
