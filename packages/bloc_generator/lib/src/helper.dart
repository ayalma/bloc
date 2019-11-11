import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

TResult ifAnnotated<TAnnotation, TResult>(FieldElement element,
    TResult builder(ConstantReader reader, FieldElement fieldElement)) {
  final annotations =
      TypeChecker.fromRuntime(TAnnotation).annotationsOf(element);
  if (annotations.isEmpty) return null;
  final annotation = ConstantReader(annotations.first);
  return builder(annotation, element);
}

/// Extract a parameterized type from a field's [type].
String extractBoundTypeName(FieldElement field) {
  DartType bound = null;

  if (field.type is ParameterizedType) {
    final arguments = (field.type as ParameterizedType).typeArguments;
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
