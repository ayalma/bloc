import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'test_bloc.g.dart';

@bloc
class TestBloc extends Bloc with _TestBloc {
  @BlocStream("testStream")
  @BlocSink("runTest")
  PublishSubject<String> addComment;
}
