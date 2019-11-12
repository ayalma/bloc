import 'package:analyzer/dart/element/element.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_generator/src/helper.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

class SinkCodeBuilder {
  final String _fieldName;
  final String _argumentType;
  final String _name;

  SinkCodeBuilder(
      {@required FieldElement field,
      @required BlocSink annotation,
      String defaultName})
      : _argumentType = extractFieldBoundTypeName(field),
        this._fieldName = field.name,
        this._name =
            annotation.name ?? defaultName ?? publicName(field.name, "Sink");

  void buildGetter(ClassBuilder builder) {
    builder.methods.add(Method((b) => b
      ..name = this._name
      ..type = MethodType.getter
      ..returns = refer("Function(${this._argumentType})")
      ..lambda = true
      ..body = Code("this._parent.${_fieldName}.sink.add")));
  }

  void buildDispose(BlockBuilder builder) {
    builder.statements.add(Code("await _parent.${_fieldName}.drain();"));
    builder.statements.add(Code("_parent.${_fieldName}.close();"));
  }
}
