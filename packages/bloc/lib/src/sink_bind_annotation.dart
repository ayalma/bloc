///
/// An annotation used to specify that a field must be exposed as
/// an input [Sink] and bind method to it .
///
class SinkBind {
  ///
  /// The name of the generated [Sink] property. If not precised, the
  /// name will be deduced from the annotated field name.
  ///
  final String name;
  final String methodName;

  ///
  /// Creates a new [BlocSink] instance.
  ///
  const SinkBind([this.name, this.methodName]);
}

///
/// Default [SinkBind] annotation.
///
const sinkBind = SinkBind();
