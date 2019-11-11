import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_generator/src/sink_code_builder.dart';
import 'package:bloc_generator/src/stream_code_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'helper.dart';

class BlocModelVisitor extends SimpleElementVisitor {
  DartType className;
  List<SinkCodeBuilder> sinkCodeBuilders = [];
  List<StreamCodeBuilder> streamCodeBuilders = [];

  @override
  visitConstructorElement(ConstructorElement element) {
    assert(className == null);
    className = element.type.returnType;
  }

  @override
  visitFieldElement(FieldElement element) {
    var result = _scanForSink(element);
    _scanForStream(element, result);
  }

  bool _scanForSink(FieldElement element) {
    var sinkGenerator = ifAnnotated<BlocSink, SinkCodeBuilder>(
      element,
      (ConstantReader reader, FieldElement fieldElement) => SinkCodeBuilder(
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
      (ConstantReader reader, FieldElement fieldElement) => StreamCodeBuilder(
          field: fieldElement,
          annotation: _streamFromConstantReader(reader),
          buildClose: !isSinkPresent),
    );

    if (streamCodeBuilder != null) streamCodeBuilders.add(streamCodeBuilder);
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
}
