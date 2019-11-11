import 'package:analyzer/dart/element/element.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_generator/src/bloc_code_builder.dart';
import 'package:bloc_generator/src/bloc_model_visitor.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

class BlocGenerator extends GeneratorForAnnotation<BuiltBloc> {
  @override
  Iterable<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is ClassElement) {
      BlocModelVisitor visitor = BlocModelVisitor(element);
      element.visitChildren(visitor);

      final codeBuilder = BlocCodeBuilder(
          visitor.className,
          visitor.sinkCodeBuilders,
          visitor.streamCodeBuilders,
          visitor.bindCodeBuilders,
          visitor.sinkBindCodeBuilders);

      return codeBuilder.buildCode();
    }

    final name = element.name;
    throw InvalidGenerationSourceError('Generator cannot target `$name`.',
        todo: 'Remove the bloc annotation from `$name`.', element: element);
  }
}
