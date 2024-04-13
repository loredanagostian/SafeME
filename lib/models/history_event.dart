class HistoryEvent {
  final DateTime startDate;
  // final DateTime endDate;
  // final int duration;

  final bool isTrackingEvent;

  HistoryEvent({
    required this.startDate,
    // required this.endDate,
    // required this.duration,
    required this.isTrackingEvent,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      // 'endDate': endDate,
      // 'duration': duration,
      'isTrackingEvent': isTrackingEvent,
    };
  }
}
