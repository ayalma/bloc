import 'package:analyzer/dart/element/element.dart';
import 'package:bloc/bloc.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import 'helper.dart';

class StreamCodeBuilder {
  final String fieldName;
  final String argumentType;
  final String name;
  final bool buildClose;

  StreamCodeBuilder({
    @required FieldElement field,
    @required BlocStream annotation,
    this.buildClose,
  })  : argumentType = extractBoundTypeName(field),
        this.fieldName = field.name,
        this.name = annotation.name ?? publicName(field.name, "Stream");

  void buildGetter(ClassBuilder builder) {
    builder.methods.add(Method((b) => b
      ..name = this.name
      ..type = MethodType.getter
      ..returns = refer("Stream<${this.argumentType}>")
      ..lambda = true
      ..body = Code("_parent.${fieldName}.stream")));
  }

  void buildDispose(BlockBuilder builder) {
    if (buildClose) {
      builder.statements.add(
        Code(
          "_parent.${fieldName}.close();",
        ),
      );
    }
  }
}
