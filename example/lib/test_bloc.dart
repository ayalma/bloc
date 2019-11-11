import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'test_bloc.g.dart';

@bloc
class TestBloc extends Bloc with _TestBloc {
  @SinkBind('runTest', '_onRunTest')
  PublishSubject<String> addComment;

  @BlocStream("result")
  PublishSubject<int> result = PublishSubject();
  void _onRunTest(String event) {}
}
