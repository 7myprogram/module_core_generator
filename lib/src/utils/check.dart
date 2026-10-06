import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class Check {
  static bool isType(FieldElement element) {
    final value = element.computeConstantValue();
    return value != null && value.type?.getDisplayString() == 'Type';
  }

  static bool isListOfType(FieldElement element) {
    final value = element.computeConstantValue();
    return value != null && value.type?.getDisplayString() == 'List<Type>';
  }

  static bool isListOfRecordTypeType(FieldElement element) {
    final value = element.computeConstantValue();
    return value != null &&
        value.type?.getDisplayString() == 'List<(Type, Type)>';
  }

  static bool isSubclassOf(ClassElement element, String targetName) {
    return element.allSupertypes.any((type) => type.element.name == targetName);
  }

  static bool hasDefaultConstructor(DartType? type) {
    if (type == null) {
      return false;
    }

    final element = type.element;
    if (element is! ClassElement) {
      return false;
    }

    final constructors = element.constructors;
    for (final constructor in constructors) {
      if (constructor.isDefaultConstructor) {
        return true;
      }
    }

    return false;
  }

  static bool exportFiles(LibraryElement? library) {
    if (library == null) {
      return false;
    }
    return library.firstFragment.libraryExports.isNotEmpty;
  }
}
