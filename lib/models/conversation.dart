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

    // Corregir el manejo del campo is_group
    bool isGroupValue = false;
    if (json['is_group'] != null) {
      // Si es un entero, convertir a booleano (0 = false, cualquier otro valor = true)
      if (json['is_group'] is int) {
        isGroupValue = json['is_group'] != 0;
      }
      // Si ya es booleano, usarlo directamente
      else if (json['is_group'] is bool) {
        isGroupValue = json['is_group'];
      }
      // Si es string, convertir a booleano
      else if (json['is_group'] is String) {
        isGroupValue =
            json['is_group'].toLowerCase() == 'true' || json['is_group'] == '1';
      }
    }

    return Conversation(
      id: json['id'],
      name: json['name'] ?? '',
      isGroup: isGroupValue,
      users: usersList,
      lastMessage: lastMsg,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
