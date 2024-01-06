class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool opened;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.opened = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String id = json['id'];
    String title = json['title'];
    String body = json['body'];
    bool opened = json['opened'];

    return NotificationModel(
      id: id,
      title: title,
      body: body,
      opened: opened,
    );
  }
}
