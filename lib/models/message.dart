import 'package:frontend/components/components.dart';
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

  // Campos adicionales para gestionar mejor el estado del mensaje
  final bool isPending; // Indica si el mensaje está pendiente de envío
  final bool isFailed; // Indica si falló el envío del mensaje

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
    this.isPending = false,
    this.isFailed = false,
  });

  // Crear una copia del mensaje con estados actualizados
  Message copyWith({
    int? id,
    int? conversationId,
    int? userId,
    User? user,
    String? text,
    bool? isMe,
    bool? read,
    String? time,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPending,
    bool? isFailed,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      read: read ?? this.read,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPending: isPending ?? this.isPending,
      isFailed: isFailed ?? this.isFailed,
    );
  }

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

    DateTime? createdAtDate;
    String formattedTime = '';
    try {
      if (json['created_at'] != null) {
        createdAtDate = DateTime.parse(json['created_at']);

        // Usar la utilidad para formatear con el ajuste manual de zona horaria
        formattedTime = TimeUtils.formatTimeWithAmPm(createdAtDate);
      } else {
        // Si no hay created_at, usar hora actual
        formattedTime = TimeUtils.formatTimeWithAmPm(DateTime.now());
      }
    } catch (e) {
      print('Error al parsear created_at: $e');
      formattedTime = TimeUtils.formatTimeWithAmPm(DateTime.now());
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

    // Determinar si el mensaje es del usuario actual
    bool isMe = false;
    if (json.containsKey('is_me')) {
      isMe = json['is_me'] == true;
    }

    // Determinar si el mensaje está pendiente o falló
    bool isPending = json['is_pending'] == true;
    bool isFailed = json['is_failed'] == true;

    return Message(
      id: messageId,
      conversationId: conversationId,
      userId: userId,
      user: messageUser,
      text: messageText,
      isMe: isMe,
      read: json['read'] == true || json['read'] == 1,
      time: formattedTime,
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
      isPending: isPending,
      isFailed: isFailed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'content': text,
      'read': read,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_pending': isPending,
      'is_failed': isFailed,
    };
  }

  // Crear un mensaje local pendiente
  factory Message.pendingLocal({
    required int tempId,
    required int conversationId,
    required int userId,
    required String text,
  }) {
    final now = DateTime.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Message(
      id: tempId, // ID temporal negativo
      conversationId: conversationId,
      userId: userId,
      text: text,
      isMe: true,
      read: false,
      time: formattedTime,
      createdAt: now,
      updatedAt: now,
      isPending: true,
      isFailed: false,
    );
  }

  // Marcar mensaje como fallido
  Message markAsFailed() {
    return copyWith(
      isPending: false,
      isFailed: true,
      updatedAt: DateTime.now(),
    );
  }

  // Marcar mensaje como enviado
  Message markAsSent({int? serverId}) {
    return copyWith(
      id: serverId ?? id,
      isPending: false,
      isFailed: false,
      updatedAt: DateTime.now(),
    );
  }
}
