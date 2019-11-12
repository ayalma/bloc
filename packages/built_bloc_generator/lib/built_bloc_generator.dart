import 'package:build/build.dart';
import 'package:built_bloc_generator/src/bloc_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder blocGenerator(BuilderOptions options) =>
    SharedPartBuilder([BlocGenerator()], 'bloc_generator');
