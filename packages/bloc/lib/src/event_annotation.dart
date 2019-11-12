class EventStream {
  final String eventName;
  final String stateName;
  final SubjectType eventSubjectType;
  final SubjectType stateSubjectType;

  const EventStream([
    this.eventName,
    this.stateName,
    this.eventSubjectType = SubjectType.PublishSubject,
    this.stateSubjectType = SubjectType.BehaviorSubject,
  ]);
}

enum SubjectType {
  PublishSubject,
  BehaviorSubject,
  ReplaySubject,
}
