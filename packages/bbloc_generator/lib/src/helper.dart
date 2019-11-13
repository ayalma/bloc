import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

TResult ifAnnotated<TAnnotation, TResult>(Element element,
    TResult builder(ConstantReader reader, Element fieldElement)) {
  final annotations =
      TypeChecker.fromRuntime(TAnnotation).annotationsOf(element);
  if (annotations.isEmpty) return null;
  final annotation = ConstantReader(annotations.first);
  return builder(annotation, element);
}

/// Extract a parameterized type from a field's [type].
String extractFieldBoundTypeName(FieldElement field) =>
    extractTypeBoundTypeName(field.type);

String extractTypeBoundTypeName(DartType type) {
  DartType bound;

  if (type is ParameterizedType) {
    final arguments = type.typeArguments;
    if (arguments.isNotEmpty) {
      bound = arguments.first;
    }
  }

  if (bound == null || bound.isVoid) {
    return "void";
  }

  return bound.toString();
}

String publicName(String name, String suffixIfNotPrivate) {
  if (name.startsWith("_")) {
    return name.substring(1);
  }
  return "$name$suffixIfNotPrivate";
}

String privateName(String name, String suffixIfNotPublic) {
  if (name.startsWith("_")) {
    return "$name$suffixIfNotPublic";
  }
  return "_$name";
}
