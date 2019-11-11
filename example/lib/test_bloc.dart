import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';

part 'test_bloc.g.dart';

@bloc
class TestBloc extends Bloc with _TestBloc {
  @sink
  PublishSubject<String> addComment;
}
