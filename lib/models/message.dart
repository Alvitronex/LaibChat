import 'package:frontend/models/models.dart';

class Message {
  final int? id;
  final int? conversationId;
  final int? userId;
  final User? user;
  final String text;
  final bool isMe;
  final bool read;
  final String time;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Message({
    this.id,
    this.conversationId,
    this.userId,
    this.user,
    required this.text,
    required this.isMe,
    this.read = false,
    required this.time,
    this.createdAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Convertir la fecha a un formato de hora legible
    final DateTime createdAt = DateTime.parse(json['created_at']);
    final String formattedTime =
        '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';

    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      userId: json['user_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      text: json['content'],
      isMe: json['is_me'] ?? false, // Esto se configurará en el servicio
      read: json['read'] ?? false,
      time: formattedTime,
      createdAt: createdAt,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'content': text,
      'read': read,
    };
  }
}
