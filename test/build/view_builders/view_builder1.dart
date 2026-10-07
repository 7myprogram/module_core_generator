import 'package:module_core/module_core.dart';

class Screen1 {}

class ViewBuilder1 extends ViewBuilderAttachment<Screen1> {
  @override
  Screen1 buildScreen(args) {
    return Screen1();
  }
}
