import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/components/components.dart';
import 'package:frontend/models/models.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/services.dart';

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final String name;
  final String? imageUrl;

  const ChatDetailScreen({
    Key? key,
    required this.conversationId,
    required this.name,
    this.imageUrl,
  }) : super(key: key);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isSending = false;
  bool _hasAttemptedLoad = false;
  int _retryCount = 0;
  Timer? _updateTimer;
  bool _isScreenVisible = true;
  bool _isAutoRefresh = false;
  // Cola de mensajes pendientes para gestionar múltiples envíos consecutivos
  final List<Map<String, dynamic>> _pendingMessages = [];
  // Usar UUID para generar IDs temporales consistentes
  int _tempMessageId = 0;
  bool _processingQueue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMessageUpdateTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages(isAutoRefresh: false);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Controlar cuando la app está en primer/segundo plano
    _isScreenVisible = state == AppLifecycleState.resumed;

    // Si vuelve a primer plano, actualizar mensajes
    if (_isScreenVisible) {
      _loadMessages(isAutoRefresh: true);
    } else {
      // Pausar procesamiento en segundo plano para ahorrar recursos
      _processingQueue = false;
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startMessageUpdateTimer() {
    // Cancelar timer existente si hay uno
    _updateTimer?.cancel();

    // Crear un nuevo timer - reducido a 10 segundos para mayor fluidez en tiempo real
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _isScreenVisible) {
        _loadMessages(isAutoRefresh: true);
      }
    });
  }

  Future<void> _loadMessages({bool isAutoRefresh = false}) async {
    // Solo contamos reintentos para carga manual, no para actualizaciones automáticas
    if (!isAutoRefresh) {
      if (_errorMessage.isNotEmpty && _hasAttemptedLoad) {
        _retryCount += 1;
      }

      if (_hasAttemptedLoad && _retryCount >= 3) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Demasiados intentos. Intenta de nuevo más tarde.';
        });
        return;
      }

      setState(() {
        _hasAttemptedLoad = true;
      });
    }

    // No mostramos carga ni cambiamos mensajes para actualizaciones automáticas
    if (!isAutoRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    if (!authService.authenticated) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No has iniciado sesión';
      });
      return;
    }

    try {
      final token = authService.token;
      if (token != null) {
        // Usar parámetro timestamp para obtener solo mensajes nuevos (optimización)
        final lastMessageTimestamp =
            _getLastMessageTimestamp(chatService, widget.conversationId);

        await chatService.fetchMessages(
            token, widget.conversationId, authService.user.id,
            lastTimestamp: lastMessageTimestamp);

        // Solo actualizamos UI si hay mensajes o no es actualización automática
        if (!isAutoRefresh ||
            chatService.getMessages(widget.conversationId).isNotEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = '';
          });

          // Desplazar al final cuando se carguen los mensajes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    } catch (e) {
      // Solo mostramos errores en actualizaciones manuales
      if (!isAutoRefresh) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar mensajes: $e';
        });
      }
      print('Error detallado al cargar mensajes: $e');
    }
  }

  // Obtener el timestamp del último mensaje para optimizar fetching
  String? _getLastMessageTimestamp(
      ChatService chatService, int conversationId) {
    final messages = chatService.getMessages(conversationId);
    if (messages.isNotEmpty && messages.last.createdAt != null) {
      return messages.last.createdAt!.toIso8601String();
    }
    return null;
  }

  void _resetRetryCount() {
    setState(() {
      _retryCount = 0;
      _errorMessage = '';
    });
    _loadMessages(isAutoRefresh: false);
  }

  void _scrollToBottom() {
    try {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      print('Error al desplazar al final: $e');
    }
  }

  // Sistema de cola optimizado para mensajes consecutivos rápidos
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) return;

    // Limpiar el campo de texto inmediatamente
    _messageController.clear();

    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    if (!authService.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has iniciado sesión')),
      );
      return;
    }

    // Crear un ID temporal único para este mensaje
    final tempId =
        --_tempMessageId; // Usar números negativos para IDs temporales

    final now = DateTime.now();
    final formattedTime = TimeUtils.formatTimeWithAmPm(now);

    final localMessage = Message(
      id: tempId, // ID temporal negativo para distinguirlo
      conversationId: widget.conversationId,
      userId: authService.user.id,
      user: null,
      text: message,
      isMe: true,
      read: false,
      time: formattedTime,
      createdAt: now,
      updatedAt: now,
    );

    // Añadir a la cola de mensajes pendientes
    _pendingMessages.add({
      'message': message,
      'tempId': tempId,
      'timestamp': now.millisecondsSinceEpoch,
    });

    // Actualizar UI inmediatamente con el mensaje local
    setState(() {
      // Añadir mensaje a la lista local de ChatService
      chatService.addLocalMessage(widget.conversationId, localMessage);

      // Mostrar indicador de envío solo si no hay procesamiento activo
      if (!_processingQueue) {
        _isSending = true;
      }
    });

    // Desplazar al final inmediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Procesar la cola de mensajes si no está ya en proceso
    if (!_processingQueue) {
      _processMessageQueue(authService, chatService);
    }
  }

  // Procesar mensajes en cola para asegurar orden y timestamps correctos
  Future<void> _processMessageQueue(
      AuthService authService, ChatService chatService) async {
    if (_pendingMessages.isEmpty || _processingQueue) return;

    _processingQueue = true;

    while (_pendingMessages.isNotEmpty) {
      if (!mounted) break;

      // Tomar el primer mensaje de la cola
      final pendingMessage = _pendingMessages.first;
      final message = pendingMessage['message'] as String;
      final tempId = pendingMessage['tempId'] as int;

      try {
        final token = authService.token;
        if (token != null) {
          // Enviar mensaje al servidor
          final serverMessage = await chatService.sendMessage(
              token, widget.conversationId, message, authService.user.id,
              tempId: tempId);

          if (mounted) {
            // Mensaje enviado correctamente, actualizar UI si es necesario
            print('Mensaje enviado con éxito: ${serverMessage?.id}');
          }
        }
      } catch (e) {
        if (mounted) {
          // Marcar mensaje como fallido pero mantenerlo visible
          chatService.markMessageAsFailed(widget.conversationId, tempId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al enviar mensaje: $e'),
              backgroundColor: Colors.red[100],
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Reintentar',
                onPressed: () => _resendMessage(message, tempId),
              ),
            ),
          );
        }
      }

      // Remover el mensaje procesado de la cola
      _pendingMessages.removeAt(0);

      // Pequeña pausa entre mensajes para asegurar orden correcto
      if (_pendingMessages.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    if (mounted) {
      setState(() {
        _isSending = false;
        _processingQueue = false;
      });
    }
  }

  // Reenviar un mensaje fallido
  Future<void> _resendMessage(String messageText, int tempId) async {
    if (messageText.isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    // Añadir nuevamente a la cola de mensajes pendientes con prioridad
    _pendingMessages.insert(0, {
      'message': messageText,
      'tempId': tempId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    setState(() {
      // Actualizar estado del mensaje a "enviando" nuevamente
      chatService.updateMessageStatus(widget.conversationId, tempId,
          isSending: true);
    });

    // Procesar cola si no está en proceso
    if (!_processingQueue) {
      _processMessageQueue(authService, chatService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final messages = chatService.getMessages(widget.conversationId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leadingWidth: 30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? NetworkImage(widget.imageUrl!) as ImageProvider
                      : null,
              backgroundColor: Colors.purple[100],
              child: (widget.imageUrl == null || widget.imageUrl!.isEmpty)
                  ? Text(
                      widget.name.isNotEmpty
                          ? widget.name[0].toUpperCase()
                          : "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _isLoading ? null : _resetRetryCount,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mensaje de error si existe
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red[100],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    color: Colors.red[700],
                    onPressed: _resetRetryCount,
                  ),
                ],
              ),
            ),

          // Contenido principal
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando mensajes...'),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay mensajes aún',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sé el primero en enviar un mensaje',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10),
                          itemCount: messages.length,
                          cacheExtent: 1000,
                          addAutomaticKeepAlives: true,
                          itemBuilder: (context, index) {
                            final message = messages[index];

                            // Calcular si debe mostrar tiempo basado en mensaje previo
                            final bool showTime = index == 0 ||
                                _shouldShowTime(messages[index],
                                    index > 0 ? messages[index - 1] : null);

                            // Usar key basada en id único para optimizar reconstrucción
                            return KeyedSubtree(
                              key: ValueKey(
                                  'msg_${message.id}_${message.text.hashCode}'),
                              child: MessageBubble(
                                message: message,
                                showTime: showTime,
                                // Mostrar estado de envío solo para mensajes propios
                                showStatus: message.isMe,
                              ),
                            );
                          },
                        ),
                ),

          // Input para escribir mensaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                    onTap: () {
                      // Desplazar al final cuando se selecciona el campo de texto
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isSending && _pendingMessages.length > 3
                        ? null
                        : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTime(Message current, Message? previous) {
    // if (previous == null) return true;

    // // Si los mensajes son de diferentes usuarios, mostrar tiempo
    // if (current.userId != previous.userId) return true;

    // // Si hay más de 2 minutos entre mensajes (reducido de 5 para más detalles temporales)
    // if (current.createdAt != null && previous.createdAt != null) {
    //   final difference = current.createdAt!.difference(previous.createdAt!);
    //   return difference.inMinutes > 2;
    // }

    return true;
  }
}

// Widget optimizado con indicador de estado de envío
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTime;
  final bool showStatus;

  const MessageBubble({
    Key? key,
    required this.message,
    this.showTime = true,
    this.showStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar el estado del mensaje
    final isFailed =
        message.id != null && message.id! < 0; // IDs negativos son temporales

    // Optimización: usar RepaintBoundary para limitar repintados innecesarios
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment:
              message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isMe)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.purple[100],
                  child: Text(
                    message.user?.name.isNotEmpty == true
                        ? message.user!.name[0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: message.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: message.isMe
                          ? (isFailed
                              ? Colors.orange.withOpacity(0.7)
                              : Colors.orange)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isMe ? Colors.white : Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  if (showTime)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.time,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.0,
                            ),
                          ),
                          if (showStatus && isFailed)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red[300],
                                size: 12,
                              ),
                            ),
                          if (showStatus &&
                              !isFailed &&
                              message.id != null &&
                              message.id! > 0)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.check,
                                color: Colors.green[300],
                                size: 12,
                              ),
                            ),
                          if (showStatus && message.id == null)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (message.isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.amber[700],
                  child: const Text(
                    "YO",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
