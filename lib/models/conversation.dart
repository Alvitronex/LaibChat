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
    // Asegurarse de que todos los campos existan o tengan valores por defecto
    final int conversationId = json['id'] ?? 0;
    final String conversationName = json['name'] ?? '';

    // Manejo robusto del campo is_group con manejo de varios tipos de datos
    bool isGroupValue = false;
    if (json['is_group'] != null) {
      if (json['is_group'] is int) {
        isGroupValue = json['is_group'] != 0;
      } else if (json['is_group'] is bool) {
        isGroupValue = json['is_group'];
      } else if (json['is_group'] is String) {
        isGroupValue =
            json['is_group'].toLowerCase() == 'true' || json['is_group'] == '1';
      }
    }

    // Procesamiento seguro de la lista de usuarios
    List<User> usersList = [];
    if (json['users'] != null) {
      try {
        usersList = List<User>.from(
            (json['users'] as List).map((user) => User.fromJson(user)));
      } catch (e) {
        print('Error al procesar usuarios: $e');
      }
    }

    // Procesamiento seguro del último mensaje
    Message? lastMsg;
    if (json['last_message'] != null) {
      try {
        lastMsg = Message.fromJson(json['last_message']);
      } catch (e) {
        print('Error al procesar último mensaje: $e');
      }
    }

    // Manejo seguro de fechas
    DateTime createdAtDate, updatedAtDate;
    try {
      createdAtDate = json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now();
    } catch (e) {
      print('Error al parsear created_at: $e');
      createdAtDate = DateTime.now();
    }

    try {
      updatedAtDate = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now();
    } catch (e) {
      print('Error al parsear updated_at: $e');
      updatedAtDate = DateTime.now();
    }

    return Conversation(
      id: conversationId,
      name: conversationName,
      isGroup: isGroupValue,
      users: usersList,
      lastMessage: lastMsg,
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
    );
  }
}
