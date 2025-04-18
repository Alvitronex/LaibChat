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
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print('Fetch conversations response status: ${response.statusCode}');
      print('Fetch conversations response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> conversationsJson = json.decode(response.body);
          _conversations = conversationsJson
              .map((json) => Conversation.fromJson(json))
              .toList();
          notifyListeners();
          return _conversations;
        } catch (e) {
          print('Error decodificando conversaciones: $e');
          throw Exception('Error al procesar datos de conversaciones: $e');
        }
      } else {
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
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/conversations/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print('Fetch messages response status: ${response.statusCode}');
      if (response.body.length < 500) {
        print('Fetch messages response body: ${response.body}');
      } else {
        print('Fetch messages response body: (respuesta larga)');
      }

      if (response.statusCode == 200) {
        try {
          final List<dynamic> messagesJson = json.decode(response.body);
          final List<Message> messages = messagesJson.map((json) {
            // Añadir isMe basado en el ID del usuario
            final message = Message.fromJson(json);
            return Message(
              id: message.id,
              conversationId: message.conversationId,
              userId: message.userId,
              user: message.user,
              text: message.text,
              isMe: message.userId == currentUserId,
              read: message.read,
              time: message.time,
              createdAt: message.createdAt,
              updatedAt: message.updatedAt,
            );
          }).toList();

          _messages[conversationId] = messages;
          notifyListeners();
          return messages;
        } catch (e) {
          print('Error decodificando mensajes: $e');
          throw Exception('Error al procesar datos de mensajes: $e');
        }
      } else {
        throw Exception('Error al cargar mensajes: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en fetchMessages: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Enviar un mensaje
  Future<Message?> sendMessage(String token, int conversationId, String content,
      int currentUserId) async {
    try {
      final response = await http.post(
        Uri.parse('${servidor.baseUrl}/conversations/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'content': content}),
      );

      print('Send message response status: ${response.statusCode}');
      print('Send message response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final messageJson = json.decode(response.body);
          final message = Message.fromJson(messageJson);

          // Crear mensaje con isMe=true ya que lo estamos enviando nosotros
          final newMessage = Message(
            id: message.id,
            conversationId: message.conversationId,
            userId: message.userId,
            user: message.user,
            text: message.text,
            isMe: true, // Mensaje enviado por el usuario actual
            read: message.read,
            time: message.time,
            createdAt: message.createdAt,
            updatedAt: message.updatedAt,
          );

          // Añadir a la lista de mensajes
          if (_messages.containsKey(conversationId)) {
            _messages[conversationId]!.add(newMessage);
          } else {
            _messages[conversationId] = [newMessage];
          }

          notifyListeners();
          return newMessage;
        } catch (e) {
          print('Error decodificando mensaje enviado: $e');
          throw Exception('Error al procesar datos del mensaje: $e');
        }
      } else {
        throw Exception('Error al enviar mensaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en sendMessage: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener usuarios disponibles para chat
  Future<List<User>> fetchAvailableUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${servidor.baseUrl}/chat/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print('Fetch available users response status: ${response.statusCode}');
      print('Fetch available users response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> usersJson = json.decode(response.body);
          _availableUsers =
              usersJson.map((json) => User.fromJson(json)).toList();
          notifyListeners();
          return _availableUsers;
        } catch (e) {
          print('Error decodificando usuarios disponibles: $e');
          throw Exception('Error al procesar datos de usuarios: $e');
        }
      } else {
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
      final response = await http.post(
        Uri.parse('${servidor.baseUrl}/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'user_ids': userIds,
          'name': name,
          'is_group': isGroup,
        }),
      );

      print('Create conversation response status: ${response.statusCode}');
      print('Create conversation response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          final conversation =
              Conversation.fromJson(responseData['conversation']);

          // Añadir a la lista de conversaciones
          _conversations.add(conversation);
          notifyListeners();

          return conversation;
        } catch (e) {
          print('Error decodificando conversación creada: $e');
          throw Exception('Error al procesar datos de la conversación: $e');
        }
      } else {
        throw Exception('Error al crear conversación: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción en createConversation: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
