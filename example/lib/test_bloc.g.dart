// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_bloc.dart';

// **************************************************************************
// BlocGenerator
// **************************************************************************

class _TestBloc implements GeneratedBloc<TestBloc> {
  TestBloc _parent;

  Function(String) get addCommentSink => this._parent.addComment.sink.add;
  @override
  void subscribeParent(TestBloc value) {
    this._parent = value;
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    await _parent.addComment.drain();
    _parent.addComment.close();
  }
}
