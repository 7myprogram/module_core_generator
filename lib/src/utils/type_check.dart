import 'package:analyzer/dart/element/element.dart';

class TypeCheck {
  static bool isType(FieldElement element) {
    final value = element.computeConstantValue();
    return value != null && value.type?.getDisplayString() == 'Type';
  }

  static bool isListOfRecordTypeType(FieldElement element) {
    final value = element.computeConstantValue();
    return value != null &&
        value.type?.getDisplayString() == 'List<(Type, Type)>';
  }
}
