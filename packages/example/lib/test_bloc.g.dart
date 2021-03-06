// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_bloc.dart';

// **************************************************************************
// BlocGenerator
// **************************************************************************

class _TestBloc implements GeneratedBloc<TestBloc> {
  final PublishSubject<String> _incrementEvent = PublishSubject();

  final BehaviorSubject<int> _incrementResultState = BehaviorSubject();

  TestBloc _parent;

  Function(String) get increment => this._incrementEvent.sink.add;
  Stream<int> get incrementResult => this._incrementResultState.stream;
  Stream<int> get result => _parent._addCommentState.stream;
  Function(String) get runTest => this._parent._addComment.sink.add;
  @override
  void subscribeParent(TestBloc value) {
    this._parent = value;
    this._parent._addComment.listen(value._onAddComment);
    this
        ._incrementEvent
        .stream
        .asyncExpand(_parent._increment)
        .pipe(_incrementResultState);
  }

  @override
  @mustCallSuper
  Future<void> dispose() async {
    _parent._addCommentState.close();
    await _parent._addComment.drain();
    _parent._addComment.close();
    await this._incrementEvent.drain();
    this._incrementEvent.close();
    this._incrementResultState.close();
  }
}
