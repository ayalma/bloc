import 'dart:async';

import 'package:built_bloc/built_bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'test_bloc.g.dart';

@bloc
class TestBloc extends Bloc with _TestBloc {
  @SinkBind('runTest', '_onAddComment')
  PublishSubject<String> _addComment;

  @BlocStream("result")
  PublishSubject<int> _addCommentState = PublishSubject();

  _onAddComment(String event) {}

  int _i = 0;

  @EventStream(
    "increment",
    "incrementResult",
  )
  Stream<int> _onRunTest(String event) async* {
    yield _i++;
  }
}
