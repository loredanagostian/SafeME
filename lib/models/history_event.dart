class HistoryEvent {
  final DateTime startDate;
  final String city;
  final String country;

  final bool isTrackingEvent;

  HistoryEvent({
    required this.startDate,
    required this.isTrackingEvent,
    required this.city,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate,
      'isTrackingEvent': isTrackingEvent,
      'city': city,
      'country': country,
    };
  }
}
