import 'package:analyzer/dart/element/type.dart';
import 'package:bbloc_generator/src/bind_code_builder.dart';
import 'package:bbloc_generator/src/event_stream_code_builder.dart';
import 'package:bbloc_generator/src/helper.dart';
import 'package:bbloc_generator/src/sink_bind_code_builder.dart';
import 'package:bbloc_generator/src/sink_code_builder.dart';
import 'package:bbloc_generator/src/stream_code_builder.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

class BlocCodeBuilder {
  final DartType className;
  final List<SinkCodeBuilder> sinks;
  final List<StreamCodeBuilder> streams;
  final List<BindCodeBuilder> binds;
  final List<SinkBindCodeBuilder> sinkBinds;
  final List<EventStreamCodeBuilder> eventStreams;

  BlocCodeBuilder(this.className, this.sinks, this.streams, this.binds,
      this.sinkBinds, this.eventStreams);

  String get _name => privateName(this.className.name, "Generated");

  List<String> buildCode() {
    var library =
        Library((b) => b..body.addAll([buildMixin()])..directives.addAll([]));

    var emitter = DartEmitter();
    var source = '${library.accept(emitter)}';
    return [DartFormatter().format(source)];
  }

  Class buildMixin() {
    final builder = ClassBuilder()
      ..name = this._name
      ..implements.add(refer("GeneratedBloc<${className.name}>"));

    eventStreams.forEach((es) {
      es.buildFields(builder);
      es.buildGutters(builder);
    });
    builder.fields.add(Field((b) => b
      ..name = "_parent"
      ..type = refer(className.name)));

    this.streams.forEach((s) => s.buildGetter(builder));
    this.sinks.forEach((s) => s.buildGetter(builder));
    this.sinkBinds.forEach((s) => s.buildGetter(builder));

    // builder.methods.add(this.buildMetadata());

    this.buildSubscription(builder);

    this.buildDispose(builder);

    return builder.build();
  }

  void buildSubscription(ClassBuilder builder) {
    final block = BlockBuilder();
    block.statements.add(Code("this._parent = value;"));
    this.binds.forEach((b) => b.buildSubscription(block));
    this.sinkBinds.forEach((sb) => sb.buildSubscription(block));
    this.eventStreams.forEach((es) => es.buildSubscription(block));

    builder.methods.add(Method((b) => b
      ..name = "subscribeParent"
      ..annotations.add(CodeExpression(Code("override")))
      ..returns = refer("void")
      ..body = block.build()
      ..requiredParameters.add(Parameter((b) => b
        ..name = "value"
        ..type = refer(this.className.name)))));
  }

  void buildDispose(ClassBuilder builder) {
    final block = BlockBuilder();
    this.sinks.forEach((s) => s.buildDispose(block));
    this.streams.forEach((s) => s.buildDispose(block));
    this.sinkBinds.forEach((sb) => sb.buildDispose(block));
    this.eventStreams.forEach((es) => es.buildDispose(block));

    builder.methods.add(Method((b) => b
      ..name = "dispose"
      ..modifier = MethodModifier.async
      ..annotations.add(CodeExpression(Code("override")))
      ..annotations.add(CodeExpression(Code("mustCallSuper")))
      ..returns = refer("Future<void>")
      ..body = block.build()));
  }
}
