import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/conversation.dart';
import 'package:frontend/models/message.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/server.dart';
import 'package:http/http.dart' as http;

class ChatService extends ChangeNotifier {
  final Servidor servidor = Servidor();
  List<Conversation> _conversations = [];
  List<User> _availableUsers = [];
  Map<int, List<Message>> _messages = {};

  // Getters
  List<Conversation> get conversations => _conversations;
  List<User> get availableUsers => _availableUsers;
  List<Message> getMessages(int conversationId) =>
      _messages[conversationId] ?? [];

  // Obtener todas las conversaciones
  Future<List<Conversation>> fetchConversations(String token) async {
    try {
      print(
          'Obteniendo conversaciones con token: ${token.substring(0, 10)}...');
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print(
          'Respuesta del servidor (fetchConversations): ${response.statusCode}');

      // Imprimir el cuerpo de la respuesta si es pequeño o solo primeros caracteres si es grande
      if (response.body.length < 300) {
        print('Cuerpo: ${response.body}');
      } else {
        print(
            'Cuerpo (primeros 300 caracteres): ${response.body.substring(0, 300)}...');
      }

      if (response.statusCode == 200) {
        try {
          // Decodificar la respuesta JSON
          final dynamic decodedResponse = json.decode(response.body);
          List<dynamic> conversationsJson;

          // Manejar diferentes formatos de respuesta
          if (decodedResponse is List) {
            conversationsJson = decodedResponse;
          } else if (decodedResponse is Map &&
              decodedResponse.containsKey('data')) {
            conversationsJson = decodedResponse['data'] as List;
          } else {
            throw Exception('Formato de respuesta inesperado');
          }

          print('Procesando ${conversationsJson.length} conversaciones');

          // Convertir cada elemento JSON a objeto Conversation
          _conversations = [];
          for (var i = 0; i < conversationsJson.length; i++) {
            try {
              final conversation = Conversation.fromJson(conversationsJson[i]);
              _conversations.add(conversation);
            } catch (e) {
              print('Error al procesar conversación $i: $e');
            }
          }

          notifyListeners();
          return _conversations;
        } catch (e) {
          print('Error decodificando conversaciones: $e');
          throw Exception('Error al procesar datos de conversaciones: $e');
        }
      } else {
        print('Error HTTP: ${response.statusCode}, Cuerpo: ${response.body}');
        throw Exception(
            'Error al cargar conversaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en fetchConversations: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener mensajes de una conversación
  Future<List<Message>> fetchMessages(
      String token, int conversationId, int currentUserId) async {
    try {
      print('Obteniendo mensajes para conversación $conversationId');
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/conversations/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print('Respuesta del servidor (fetchMessages): ${response.statusCode}');

      // Para depuración, imprimir la respuesta si es pequeña
      if (response.body.length < 300) {
        print('Cuerpo: ${response.body}');
      } else {
        print(
            'Cuerpo (primeros 300 caracteres): ${response.body.substring(0, 300)}...');
      }

      if (response.statusCode == 200) {
        try {
          // Decodificar la respuesta JSON
          final dynamic decodedResponse = json.decode(response.body);
          List<dynamic> messagesJson;

          // Manejar diferentes formatos de respuesta
          if (decodedResponse is List) {
            messagesJson = decodedResponse;
          } else if (decodedResponse is Map &&
              decodedResponse.containsKey('data')) {
            messagesJson = decodedResponse['data'] as List;
          } else {
            throw Exception('Formato de respuesta inesperado');
          }

          print('Procesando ${messagesJson.length} mensajes');

          // Crear lista para los mensajes procesados
          final List<Message> messages = [];

          // Procesar cada mensaje
          for (var i = 0; i < messagesJson.length; i++) {
            try {
              final messageData = messagesJson[i];

              // Añadir explícitamente la propiedad is_me para mejor manejo
              messageData['is_me'] = messageData['user_id'] == currentUserId;

              // Parsear el mensaje con la propiedad is_me ya incluida
              Message message = Message.fromJson(messageData);
              messages.add(message);
            } catch (e) {
              print('Error al procesar mensaje $i: $e');
            }
          }

          // Ordenar mensajes por fecha de creación (más antiguos primero)
          messages.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return a.createdAt!.compareTo(b.createdAt!);
          });

          // Guardar los mensajes procesados
          _messages[conversationId] = messages;
          notifyListeners();
          return messages;
        } catch (e) {
          print('Error decodificando mensajes: $e');
          throw Exception('Error al procesar datos de mensajes: $e');
        }
      } else {
        print('Error HTTP: ${response.statusCode}, Cuerpo: ${response.body}');
        throw Exception('Error al cargar mensajes: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en fetchMessages: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Enviar un mensaje
  // Reemplaza el método sendMessage en ChatService.dart con esta versión optimizada
  Future<Message?> sendMessage(String token, int conversationId, String content,
      int currentUserId) async {
    try {
      // Crear mensaje local inmediatamente
      final now = DateTime.now();
      final formattedTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final localMessage = Message(
        id: null,
        conversationId: conversationId,
        userId: currentUserId,
        user: null,
        text: content,
        isMe: true,
        read: false,
        time: formattedTime,
        createdAt: now,
        updatedAt: now,
      );

      // Actualizar el estado local inmediatamente (mejor UX)
      if (_messages.containsKey(conversationId)) {
        _messages[conversationId]!.add(localMessage);
      } else {
        _messages[conversationId] = [localMessage];
      }

      // Notificar a los listeners inmediatamente (actualiza la UI)
      notifyListeners();

      // Enviar mensaje al servidor en segundo plano
      print('Enviando mensaje a conversación $conversationId: "$content"');
      final Map<String, dynamic> requestBody = {'content': content};
      final String encodedBody = json.encode(requestBody);

      final response = await http.post(
        Uri.parse('${servidor.baseUrl}/conversations/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: encodedBody,
      );

      print('Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          // Procesar respuesta del servidor
          final messageJson = json.decode(response.body);
          final Map<String, dynamic> messageData =
              messageJson is Map && messageJson.containsKey('data')
                  ? messageJson['data']
                  : messageJson;

          messageData['is_me'] = true;

          // Crear objeto de mensaje con datos del servidor
          final serverMessage = Message.fromJson(messageData);

          // Buscar y reemplazar el mensaje local por el del servidor
          if (_messages.containsKey(conversationId)) {
            final index = _messages[conversationId]!
                .indexWhere((m) => m.text == content && m.id == null && m.isMe);

            if (index != -1) {
              _messages[conversationId]![index] = serverMessage;
              // Notificar actualización (aunque podría ser innecesario visualmente)
              notifyListeners();
            }
          }

          return serverMessage;
        } catch (e) {
          print('Error al procesar respuesta: $e');
          return localMessage; // Devolver el mensaje local si hay error
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        return localMessage; // Devolver el mensaje local si hay error HTTP
      }
    } catch (e) {
      print('Error en sendMessage: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener usuarios disponibles para chat
  Future<List<User>> fetchAvailableUsers(String token) async {
    try {
      print('Obteniendo usuarios disponibles');
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/chat/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print(
          'Respuesta del servidor (fetchAvailableUsers): ${response.statusCode}');
      print('Cuerpo: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Decodificar la respuesta
          final dynamic decodedResponse = json.decode(response.body);
          List<dynamic> usersJson;

          // Manejar diferentes formatos de respuesta
          if (decodedResponse is List) {
            usersJson = decodedResponse;
          } else if (decodedResponse is Map &&
              decodedResponse.containsKey('data')) {
            usersJson = decodedResponse['data'] as List;
          } else {
            throw Exception('Formato de respuesta inesperado');
          }

          print('Procesando ${usersJson.length} usuarios');

          // Procesar cada usuario
          _availableUsers = [];
          for (var i = 0; i < usersJson.length; i++) {
            try {
              final user = User.fromJson(usersJson[i]);
              _availableUsers.add(user);
            } catch (e) {
              print('Error al procesar usuario $i: $e');
            }
          }

          notifyListeners();
          return _availableUsers;
        } catch (e) {
          print('Error decodificando usuarios disponibles: $e');
          throw Exception('Error al procesar datos de usuarios: $e');
        }
      } else {
        print('Error HTTP: ${response.statusCode}, Cuerpo: ${response.body}');
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en fetchAvailableUsers: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear una nueva conversación
  Future<Conversation?> createConversation(String token, List<int> userIds,
      {String? name, bool isGroup = false}) async {
    try {
      print('Creando conversación con usuarios: $userIds');

      // Crear el cuerpo de la solicitud
      final Map<String, dynamic> requestBody = {
        'user_ids': userIds,
        'name': name,
        'is_group': isGroup,
      };

      final response = await http.post(
        Uri.parse('${servidor.baseUrl}/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(requestBody),
      );

      print(
          'Respuesta del servidor (createConversation): ${response.statusCode}');
      print('Cuerpo: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Decodificar la respuesta
          final responseData = json.decode(response.body);

          // Determinar dónde está el objeto de conversación
          final conversationData =
              responseData is Map && responseData.containsKey('conversation')
                  ? responseData['conversation']
                  : responseData;

          // Crear el objeto de conversación
          final conversation = Conversation.fromJson(conversationData);

          // Añadir a la lista de conversaciones
          _conversations.add(conversation);
          notifyListeners();

          return conversation;
        } catch (e) {
          print('Error decodificando conversación creada: $e');
          throw Exception('Error al procesar datos de la conversación: $e');
        }
      } else {
        print('Error HTTP: ${response.statusCode}, Cuerpo: ${response.body}');
        throw Exception('Error al crear conversación: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en createConversation: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para limpiar todas las conversaciones y mensajes (útil al cerrar sesión)
  void clearAll() {
    _conversations = [];
    _availableUsers = [];
    _messages = {};
    notifyListeners();
  }
}
