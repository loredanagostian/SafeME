class Notification {
  final String id;
  final String title;
  final String body;
  final bool opened;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    this.opened = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    String id = json['id'];
    String title = json['title'];
    String body = json['body'];
    bool opened = json['opened'];

    return Notification(
      id: id,
      title: title,
      body: body,
      opened: opened,
    );
  }
}
