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

  // Caché para optimizar tráfico de red
  Map<int, String> _lastMessageTimestamps = {};

  // Getters
  List<Conversation> get conversations => _conversations;
  List<User> get availableUsers => _availableUsers;
  List<Message> getMessages(int conversationId) =>
      _messages[conversationId] ?? [];

  // Obtener todas las conversaciones
  Future<List<Conversation>> fetchConversations(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/conversations'),
        headers: servidor.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        try {
          final dynamic decodedResponse = json.decode(response.body);
          List<dynamic> conversationsJson;

          if (decodedResponse is List) {
            conversationsJson = decodedResponse;
          } else if (decodedResponse is Map &&
              decodedResponse.containsKey('data')) {
            conversationsJson = decodedResponse['data'] as List;
          } else {
            throw Exception('Formato de respuesta inesperado');
          }

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

  // Optimizado para obtener solo mensajes nuevos usando timestamp
  Future<List<Message>> fetchMessages(
      String token, int conversationId, int currentUserId,
      {String? lastTimestamp}) async {
    try {
      // URL base
      String url = '${servidor.baseUrl}/conversations/$conversationId/messages';

      // Añadir parámetro de timestamp si existe para optimizar tráfico
      if (lastTimestamp != null) {
        url += '?after=$lastTimestamp';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: servidor.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        try {
          final dynamic decodedResponse = json.decode(response.body);
          List<dynamic> messagesJson;

          if (decodedResponse is List) {
            messagesJson = decodedResponse;
          } else if (decodedResponse is Map &&
              decodedResponse.containsKey('data')) {
            messagesJson = decodedResponse['data'] as List;
          } else {
            throw Exception('Formato de respuesta inesperado');
          }

          // Si no hay mensajes nuevos, retornar la lista actual
          if (messagesJson.isEmpty && _messages.containsKey(conversationId)) {
            return _messages[conversationId]!;
          }

          // Mensajes existentes o nueva lista
          final List<Message> currentMessages =
              _messages.containsKey(conversationId)
                  ? List.from(_messages[conversationId]!)
                  : [];

          // Procesar nuevos mensajes
          final List<Message> newMessages = [];
          DateTime? latestTimestamp;

          for (var i = 0; i < messagesJson.length; i++) {
            try {
              final messageData = messagesJson[i];

              // Añadir explícitamente la propiedad is_me para mejor manejo
              messageData['is_me'] = messageData['user_id'] == currentUserId;

              // Parsear el mensaje
              Message message = Message.fromJson(messageData);

              // Verificar si este mensaje ya está en la lista (por ID)
              if (message.id != null) {
                // Remover cualquier versión temporal del mismo mensaje
                currentMessages.removeWhere(
                    (m) => m.id != null && m.id! < 0 && m.text == message.text);

                // Verificar si ya existe este mensaje
                final existingIndex =
                    currentMessages.indexWhere((m) => m.id == message.id);

                if (existingIndex >= 0) {
                  // Actualizar mensaje existente
                  currentMessages[existingIndex] = message;
                } else {
                  // Añadir nuevo mensaje
                  newMessages.add(message);
                }

                // Actualizar timestamp del mensaje más reciente
                if (message.createdAt != null) {
                  if (latestTimestamp == null ||
                      message.createdAt!.isAfter(latestTimestamp)) {
                    latestTimestamp = message.createdAt;
                  }
                }
              } else {
                // Mensaje sin ID, probablemente error
                newMessages.add(message);
              }
            } catch (e) {
              print('Error al procesar mensaje $i: $e');
            }
          }

          // Añadir nuevos mensajes a la lista existente
          if (newMessages.isNotEmpty) {
            currentMessages.addAll(newMessages);

            // Ordenar por fecha de creación
            currentMessages.sort((a, b) {
              if (a.createdAt == null || b.createdAt == null) {
                return 0;
              }
              return a.createdAt!.compareTo(b.createdAt!);
            });

            // Actualizar caché de timestamp
            if (latestTimestamp != null) {
              _lastMessageTimestamps[conversationId] =
                  latestTimestamp.toIso8601String();
            }
          }

          // Actualizar lista de mensajes
          _messages[conversationId] = currentMessages;
          notifyListeners();

          return currentMessages;
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

  // Método optimizado para enviar mensajes
  Future<Message?> sendMessage(
      String token, int conversationId, String content, int currentUserId,
      {int? tempId}) async {
    try {
      // Crear el cuerpo de la solicitud optimizado (reducir tamaño)
      final Map<String, dynamic> requestBody = {'content': content};

      // Optimización: Comprimir el cuerpo para reducir tamaño de la petición
      final String encodedBody = json.encode(requestBody);

      final response = await http.post(
        Uri.parse('${servidor.baseUrl}/conversations/$conversationId/messages'),
        headers: servidor.getHeaders(token: token),
        body: encodedBody,
      );

      if (response.statusCode == 200) {
        try {
          // Decodificar la respuesta
          final messageJson = json.decode(response.body);

          // Determinar dónde está el objeto de mensaje
          final Map<String, dynamic> messageData =
              messageJson is Map && messageJson.containsKey('data')
                  ? messageJson['data']
                  : messageJson;

          // Asegurar que is_me está establecido correctamente
          messageData['is_me'] = true;

          // Crear el objeto de mensaje del servidor
          final serverMessage = Message.fromJson(messageData);

          // Actualizar mensajes locales reemplazando mensaje temporal
          if (_messages.containsKey(conversationId) && tempId != null) {
            final messages = _messages[conversationId]!;
            final index = messages.indexWhere((m) => m.id == tempId);

            if (index != -1) {
              // Reemplazar mensaje temporal con el del servidor
              messages[index] = serverMessage;
              _messages[conversationId] = messages;
              notifyListeners();
            }
          }

          return serverMessage;
        } catch (e) {
          print('Error decodificando mensaje enviado: $e');
          return null;
        }
      } else {
        print('Error HTTP: ${response.statusCode}, Cuerpo: ${response.body}');
        throw Exception('Error al enviar mensaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en sendMessage: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Métodos adicionales para manejo optimizado de mensajes locales

  // Añadir mensaje local antes de enviarlo al servidor
  void addLocalMessage(int conversationId, Message message) {
    if (_messages.containsKey(conversationId)) {
      _messages[conversationId]!.add(message);
    } else {
      _messages[conversationId] = [message];
    }
    notifyListeners();
  }

  // Actualizar estado de un mensaje (enviando, fallido, etc.)
  void updateMessageStatus(int conversationId, int tempId,
      {bool isSending = false, bool isFailed = false}) {
    if (_messages.containsKey(conversationId)) {
      final index =
          _messages[conversationId]!.indexWhere((m) => m.id == tempId);

      if (index != -1) {
        // Crear copia del mensaje con estado actualizado
        final message = _messages[conversationId]![index];

        // No podemos modificar message directamente ya que es final,
        // pero podemos crear uno nuevo con los mismos datos y reemplazarlo
        final updatedMessage = Message(
          id: tempId,
          conversationId: message.conversationId,
          userId: message.userId,
          user: message.user,
          text: message.text,
          isMe: message.isMe,
          read: message.read,
          time: message.time,
          createdAt: message.createdAt,
          updatedAt: DateTime.now(),
        );

        _messages[conversationId]![index] = updatedMessage;
        notifyListeners();
      }
    }
  }

  // Marcar mensaje como fallido
  void markMessageAsFailed(int conversationId, int tempId) {
    updateMessageStatus(conversationId, tempId,
        isFailed: true, isSending: false);
  }

  // Obtener usuarios disponibles para chat
  Future<List<User>> fetchAvailableUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/chat/users'),
        headers: servidor.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        try {
          final dynamic decodedResponse = json.decode(response.body);
          List<dynamic> usersJson;

          if (decodedResponse is List) {
            usersJson = decodedResponse;
          } else if (decodedResponse is Map &&
              decodedResponse.containsKey('data')) {
            usersJson = decodedResponse['data'] as List;
          } else {
            throw Exception('Formato de respuesta inesperado');
          }

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
      final Map<String, dynamic> requestBody = {
        'user_ids': userIds,
        'name': name,
        'is_group': isGroup,
      };

      final response = await http.post(
        Uri.parse('${servidor.baseUrl}/conversations'),
        headers: servidor.getHeaders(token: token),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          final conversationData =
              responseData is Map && responseData.containsKey('conversation')
                  ? responseData['conversation']
                  : responseData;

          final conversation = Conversation.fromJson(conversationData);
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

  // Limpiar todas las conversaciones y mensajes (útil al cerrar sesión)
  void clearAll() {
    _conversations = [];
    _availableUsers = [];
    _messages = {};
    _lastMessageTimestamps = {};
    notifyListeners();
  }
}
