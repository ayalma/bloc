import 'package:analyzer/dart/element/element.dart';
import 'package:bbloc/bbloc.dart';
import 'package:bbloc_generator/src/helper.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

class EventStreamCodeBuilder {
  final EventStream annotation;
  final MethodElement method;
  final _EventType _eventType;
  final _StateType _stateType;

  EventStreamCodeBuilder({
    @required this.method,
    @required this.annotation,
  })  : _eventType = _getEventType(annotation, method),
        _stateType = _getStateType(annotation, method);

  static _EventType _getEventType(
      EventStream annotation, MethodElement method) {
    _EventType eventType = _EventType(
        annotation.eventSubjectType.toString().replaceAll('SubjectType.', ''),
        method.parameters.first.type.name,
        privateName("_${annotation.eventName}", "Event"));
    return eventType;
  }

  static _StateType _getStateType(
      EventStream annotation, MethodElement method) {
    _StateType stateType = _StateType(
      annotation.stateSubjectType.toString().replaceAll('SubjectType.', ''),
      extractTypeBoundTypeName(method.returnType),
      privateName("_${annotation.stateName}", "State"),
    );
    return stateType;
  }

  void buildFields(ClassBuilder builder) {
    final eventSubject = FieldBuilder()
      ..name = _eventType.name
      ..modifier = FieldModifier.final$
      ..assignment = Code("${_eventType.subjectType}()")
      ..type = refer(_eventType.type);

    builder.fields.add(eventSubject.build());

    final stateSubject = FieldBuilder()
      ..name = _stateType.name
      ..modifier = FieldModifier.final$
      ..assignment = Code("${_stateType.subjectType}()")
      ..type = refer(_stateType.type);

    builder.fields.add(stateSubject.build());
  }

  void buildGutters(ClassBuilder builder) {
    final sinkMethodBuilder = MethodBuilder()
      ..name = annotation.eventName
      ..type = MethodType.getter
      ..returns = refer("Function(${_eventType.boundType})")
      ..lambda = true
      ..body = Code("this.${_eventType.name}.sink.add");
    builder.methods.add(sinkMethodBuilder.build());

    final streamMethodBuilder = MethodBuilder()
      ..name = annotation.stateName
      ..type = MethodType.getter
      ..returns = refer("Stream<${_stateType.boundType}>")
      ..lambda = true
      ..body = Code("this.${_stateType.name}.stream");
    builder.methods.add(streamMethodBuilder.build());
  }

  void buildDispose(BlockBuilder builder) {
    builder.statements.add(Code("await this.${_eventType.name}.drain();"));
    builder.statements.add(Code("this.${_eventType.name}.close();"));
    builder.statements.add(Code("this.${_stateType.name}.close();"));
  }

  void buildSubscription(BlockBuilder builder) {
    var streamName = _eventType;
//runTestEvent.stream.asyncExpand(_onRunTest).pipe(result);
    /// We call `listen` directly on [field] only if it is a stream, else we
    /// consider that the type must have a `.stream` property.
/*    final checker = TypeChecker.fromRuntime(Stream);
    if (!checker.isAssignableFromType(this.field.type)) {
      streamName += ".stream";
    }

    streamName = "this.${streamName}";

    final callback = this.argumentType == null || this.argumentType == "void"
        ? "(_) => value.${method.name}()"
        : "value.${method.name}";

    final listen = "${streamName}.listen($callback)";

     final statement = this.annotation.external
        ? "value.subscriptions.add($listen);"
        : "$listen;";
    final statement = "$listen;";*/

    final statement =
        "this.${_eventType.name}.stream.asyncExpand(_parent.${method.name}).pipe(${_stateType.name});";

    builder.statements.add(Code(statement));
  }
}

class _EventType {
  final String subjectType;
  final String boundType;
  final String name;

  _EventType(this.subjectType, this.boundType, this.name);

  String get type => "$subjectType<$boundType>";
}

class _StateType {
  final String subjectType;
  final String boundType;
  final String name;

  _StateType(this.subjectType, this.boundType, this.name);

  String get type => "$subjectType<$boundType>";
}
