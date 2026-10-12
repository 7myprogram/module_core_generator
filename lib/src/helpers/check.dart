import 'package:analyzer/dart/element/element.dart';

class Check {
  static bool isSubclassOf(
    ClassElement element, {
    Type? type,
    String? typeName,
    bool hasTypeArgs = false,
  }) {
    if (type == null && typeName == null) {
      return false;
    }
    String name = typeName ?? type.toString();
    if (hasTypeArgs) {
      name = name.replaceAll(RegExp(r'<.*>'), '');
    }
    return element.allSupertypes.any((type) => type.element.name == name);
  }

  static bool hasDefaultConstructor(ClassElement classElement) {
    final constructors = classElement.constructors;
    for (final constructor in constructors) {
      if (constructor.isDefaultConstructor) {
        return true;
      }
    }

    return false;
  }
}
