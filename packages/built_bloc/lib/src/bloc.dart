import 'package:meta/meta.dart';

///
/// A [Bloc] is an abstraction of a view that exposes only [Stream] outputs
/// and [Sink] inputs.
///
abstract class Bloc {
  ///
  /// Creates a new [Bloc] instance.
  ///
  Bloc() {
    if (this is GeneratedBloc) {
      (this as GeneratedBloc).subscribeParent(this);
    }
  }

  /// Cancel all the underlying [subscriptions] and close all [subjects].
  @mustCallSuper
  Future<void> dispose() async {}
}

/// A base class for generated mixins.
mixin GeneratedBloc<TBloc extends Bloc> {
  /// This method should registers all subscriptions
  /// on parent's bloc.
  void subscribeParent(TBloc parent) {}

  @mustCallSuper
  Future<void> dispose() async {}
}
