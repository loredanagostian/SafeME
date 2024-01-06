class Notification {
  final String title;
  final String body;
  final bool opened;

  Notification({
    required this.title,
    required this.body,
    this.opened = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    String title = json['title'];
    String body = json['body'];
    bool opened = json['opened'];

    return Notification(
      title: title,
      body: body,
      opened: opened,
    );
  }
}
