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
    // Procesamiento seguro del contenido del mensaje
    String messageText = '';
    if (json['content'] != null) {
      // Asegurar que content sea string, convertir si es necesario
      if (json['content'] is String) {
        messageText = json['content'];
      } else if (json['content'] != null) {
        // Intentar convertir cualquier otro tipo a string
        messageText = json['content'].toString();
      }
    }

    // Procesar la fecha de creación con manejo de errores
    DateTime? createdAtDate;
    String formattedTime = '';
    try {
      if (json['created_at'] != null) {
        createdAtDate = DateTime.parse(json['created_at']);
        // Formato de hora con padding para minutos y horas
        formattedTime =
            '${createdAtDate.hour.toString().padLeft(2, '0')}:${createdAtDate.minute.toString().padLeft(2, '0')}';
      } else {
        formattedTime = '--:--';
      }
    } catch (e) {
      print('Error al parsear created_at: $e');
      formattedTime = '--:--';
    }

    // Procesamiento seguro de la fecha de actualización
    DateTime? updatedAtDate;
    try {
      if (json['updated_at'] != null) {
        updatedAtDate = DateTime.parse(json['updated_at']);
      }
    } catch (e) {
      print('Error al parsear updated_at: $e');
    }

    // Determinar el usuario que envió el mensaje
    User? messageUser;
    if (json['user'] != null) {
      try {
        messageUser = User.fromJson(json['user']);
      } catch (e) {
        print('Error al procesar usuario del mensaje: $e');
      }
    }

    // Extraer ID de usuario con manejo de errores
    int? userId;
    if (json['user_id'] != null) {
      try {
        // Si es un string, intentar convertir a int
        if (json['user_id'] is String) {
          userId = int.tryParse(json['user_id']);
        } else {
          userId = json['user_id'] as int?;
        }
      } catch (e) {
        print('Error al extraer user_id: $e');
      }
    }

    // Extraer ID de conversación con manejo de errores
    int? conversationId;
    if (json['conversation_id'] != null) {
      try {
        // Si es un string, intentar convertir a int
        if (json['conversation_id'] is String) {
          conversationId = int.tryParse(json['conversation_id']);
        } else {
          conversationId = json['conversation_id'] as int?;
        }
      } catch (e) {
        print('Error al extraer conversation_id: $e');
      }
    }

    // Extraer ID del mensaje con manejo de errores
    int? messageId;
    if (json['id'] != null) {
      try {
        // Si es un string, intentar convertir a int
        if (json['id'] is String) {
          messageId = int.tryParse(json['id']);
        } else {
          messageId = json['id'] as int?;
        }
      } catch (e) {
        print('Error al extraer id: $e');
      }
    }

    return Message(
      id: messageId,
      conversationId: conversationId,
      userId: userId,
      user: messageUser,
      text: messageText,
      isMe: json['is_me'] ?? false,
      read: json['read'] ?? false,
      time: formattedTime,
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
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
