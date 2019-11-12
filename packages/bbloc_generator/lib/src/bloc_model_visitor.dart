import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:bbloc/bbloc.dart';
import 'package:bbloc_generator/src/bind_code_builder.dart';
import 'package:bbloc_generator/src/event_stream_code_builder.dart';
import 'package:bbloc_generator/src/sink_bind_code_builder.dart';
import 'package:bbloc_generator/src/sink_code_builder.dart';
import 'package:bbloc_generator/src/stream_code_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'helper.dart';

class BlocModelVisitor extends SimpleElementVisitor {
  DartType className;
  List<SinkCodeBuilder> sinkCodeBuilders = [];
  List<StreamCodeBuilder> streamCodeBuilders = [];
  List<BindCodeBuilder> bindCodeBuilders = [];
  List<SinkBindCodeBuilder> sinkBindCodeBuilders = [];
  List<EventStreamCodeBuilder> eventStreamCodeBuilders = [];

  final ClassElement _classElement;

  BlocModelVisitor(this._classElement);

  @override
  visitConstructorElement(ConstructorElement element) {
    assert(className == null);
    className = element.type.returnType;
  }

  @override
  visitMethodElement(MethodElement element) {
    var eventStreamCodeBuilder =
        ifAnnotated<EventStream, EventStreamCodeBuilder>(
      element,
      (ConstantReader reader, Element methodElement) => EventStreamCodeBuilder(
        method: methodElement,
        annotation: _eventStreamFromConstantReader(reader),
      ),
    );
    if (eventStreamCodeBuilder != null)
      eventStreamCodeBuilders.add(eventStreamCodeBuilder);
  }

  @override
  visitFieldElement(FieldElement element) {
    var result = _scanForSink(element);
    _scanForStream(element, result);
    _scanForBind(element);
    _scanForSinkBind(element);
  }

  bool _scanForSink(FieldElement element) {
    var sinkGenerator = ifAnnotated<BlocSink, SinkCodeBuilder>(
      element,
      (ConstantReader reader, Element fieldElement) => SinkCodeBuilder(
        field: fieldElement,
        annotation: _sinkFromConstantReader(reader),
      ),
    );
    if (sinkGenerator != null) sinkCodeBuilders.add(sinkGenerator);

    return sinkGenerator != null;
  }

  void _scanForStream(FieldElement element, bool isSinkPresent) {
    var streamCodeBuilder = ifAnnotated<BlocStream, StreamCodeBuilder>(
      element,
      (ConstantReader reader, Element fieldElement) => StreamCodeBuilder(
          field: fieldElement,
          annotation: _streamFromConstantReader(reader),
          buildClose: !isSinkPresent),
    );

    if (streamCodeBuilder != null) streamCodeBuilders.add(streamCodeBuilder);
  }

  void _scanForBind(FieldElement element) {
    var bindCodeBuilder = ifAnnotated<Bind, BindCodeBuilder>(
      element,
      (ConstantReader reader, Element fieldElement) => BindCodeBuilder(
        blocClass: _classElement,
        field: fieldElement,
        annotation: _bindFromConstantReader(reader),
      ),
    );

    if (bindCodeBuilder != null) bindCodeBuilders.add(bindCodeBuilder);
  }

  void _scanForSinkBind(FieldElement element) {
    var sinkBindCodeBuilder = ifAnnotated<SinkBind, SinkBindCodeBuilder>(
      element,
      (ConstantReader reader, Element fieldElement) => SinkBindCodeBuilder(
        blocClass: _classElement,
        field: fieldElement,
        annotation: _sinkBindFromConstantReader(reader),
      ),
    );

    if (sinkBindCodeBuilder != null)
      sinkBindCodeBuilders.add(sinkBindCodeBuilder);
  }

  BlocStream _streamFromConstantReader(ConstantReader reader) {
    final obj = reader.objectValue;
    final name = obj.getField("name").toStringValue();
    return BlocStream(name);
  }

  BlocSink _sinkFromConstantReader(ConstantReader reader) {
    final obj = reader.objectValue;
    final name = obj.getField("name").toStringValue();
    return BlocSink(name);
  }

  Bind _bindFromConstantReader(ConstantReader reader) {
    final obj = reader.objectValue;
    final methodName = obj.getField("methodName").toStringValue();
    //final external = obj.getField("external").toBoolValue() ?? false;
    return Bind(
      methodName,
    );
  }

  SinkBind _sinkBindFromConstantReader(ConstantReader reader) {
    final obj = reader.objectValue;
    final name = obj.getField("name").toStringValue();
    final methodName = obj.getField("methodName").toStringValue();
    return SinkBind(name, methodName);
  }

  ///
  /// extract [EventStream] from [ConstantReader]
  ///
  EventStream _eventStreamFromConstantReader(ConstantReader reader) {
    final obj = reader.objectValue;

    final eventName = obj.getField("eventName").toStringValue();
    final stateName = obj.getField("stateName").toStringValue();
    final eventSubjectType = _getSubjectType(obj.getField("eventSubjectType"));
    final stateSubjectType = _getSubjectType(obj.getField("stateSubjectType"));

    return EventStream(
      eventName,
      stateName,
      eventSubjectType,
      stateSubjectType,
    );
  }

  ///
  /// extract [SubjectType] from [DartObject]
  ///
  _getSubjectType(DartObject eventSubjectTypeObject) {
    var subjectType = null;
    SubjectType.values.forEach((s) {
      final key = s.toString().replaceAll('SubjectType.', '');
      final subjectTypeField = eventSubjectTypeObject.getField(key);
      if (subjectTypeField != null) {
        final index = subjectTypeField.toIntValue();
        subjectType = SubjectType.values[index];
      }
    });
    return subjectType;
  }
}
