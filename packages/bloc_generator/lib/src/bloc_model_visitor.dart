import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:bloc_generator/src/sink_code_builder.dart';
import 'package:source_gen/source_gen.dart';
import 'package:bloc/bloc.dart';

import 'helper.dart';

class BlocModelVisitor extends SimpleElementVisitor {
  DartType className;
  List<SinkCodeBuilder> sinkGenerators = [];

  @override
  visitConstructorElement(ConstructorElement element) {
    assert(className == null);
    className = element.type.returnType;
  }

  @override
  visitFieldElement(FieldElement element) {
    var sinkGenerator = ifAnnotated<BlocSink, SinkCodeBuilder>(
      element,
      (ConstantReader reader, FieldElement fieldElement) => SinkCodeBuilder(
        field: fieldElement,
        annotation: _readerToBlocSink(reader),
      ),
    );

    if (sinkGenerator != null) sinkGenerators.add(sinkGenerator);
  }

  _readerToBlocSink(ConstantReader reader) {
    final obj = reader.objectValue;
    final name = obj.getField("name").toStringValue();
    return BlocSink(name);
  }
}
