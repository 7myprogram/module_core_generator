import 'package:module_core/module_core.dart';

class Screen3 {}

class ViewBuilder3 with ViewBuilderAttachment<Screen3> {
  @override
  Screen3 buildScreen(args) {
    return Screen3();
  }
}
