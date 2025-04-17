import 'package:frontend/models/models.dart';

class Conversation {
  final int id;
  final String name;
  final bool isGroup;
  final List<User> users;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.users,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<User> usersList = [];
    if (json['users'] != null) {
      usersList =
          List<User>.from(json['users'].map((user) => User.fromJson(user)));
    }

    Message? lastMsg;
    if (json['last_message'] != null) {
      lastMsg = Message.fromJson(json['last_message']);
    }

    return Conversation(
      id: json['id'],
      name: json['name'] ?? '',
      isGroup: json['is_group'] ?? false,
      users: usersList,
      lastMessage: lastMsg,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
