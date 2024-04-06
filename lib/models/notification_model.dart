class NotificationModel {
  final String id;
  final String body;
  final bool opened;
  final String senderEmail;

  NotificationModel({
    required this.id,
    required this.body,
    required this.senderEmail,
    this.opened = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String id = json['id'];
    String body = json['body'];
    bool opened = json['opened'];
    String senderEmail = json['senderEmail'];

    return NotificationModel(
      id: id,
      body: body,
      opened: opened,
      senderEmail: senderEmail,
    );
  }
}
