import 'dart:async';
import 'package:flutter/material.dart';
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
  bool _isAutoRefresh =
      false; // Flag para identificar actualizaciones automáticas

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

    // Crear un nuevo timer con intervalo más largo (30 segundos en vez de 15)
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _isScreenVisible) {
        _loadMessages(isAutoRefresh: true);
      }
    });
  }

  // Añadimos un parámetro para distinguir entre actualizaciones automáticas y manuales
  Future<void> _loadMessages({bool isAutoRefresh = false}) async {
    // Solo contamos reintentos para carga manual, no para actualizaciones automáticas
    if (!isAutoRefresh) {
      // Solo incrementar contador si hay error previo y estamos intentando manualmente
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
        print(
            'Cargando mensajes para la conversación ${widget.conversationId}');
        await chatService.fetchMessages(
            token, widget.conversationId, authService.user.id);

        print('Mensajes cargados con éxito');
        print(
            'Cantidad de mensajes: ${chatService.getMessages(widget.conversationId).length}');
      }

      // Solo actualizamos UI si no es actualización automática o si hay nuevos mensajes
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

  // Método para reiniciar el contador de intentos
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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isSending) return;

    // Limpiar el campo de texto inmediatamente para mejor experiencia de usuario
    _messageController.clear();

    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    if (!authService.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No has iniciado sesión')),
      );
      return;
    }

    // Crear mensaje local inmediatamente (solo para UI)
    final now = DateTime.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final localMessage = Message(
      id: null,
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

    // Actualización optimizada de UI: Añadimos el mensaje directamente al estado local
    setState(() {
      // Obtenemos los mensajes actuales y añadimos el nuevo mensaje
      final currentMessages = chatService.getMessages(widget.conversationId);
      final List<Message> updatedMessages = List.from(currentMessages)
        ..add(localMessage);

      // Forzamos la actualización del estado visual inmediatamente
      // Esto es solo para UI, los datos reales siguen en chatService
      if (mounted) {
        _isSending = true;
      }
    });

    // Desplazar al final inmediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      final token = authService.token;
      if (token != null) {
        // Enviamos el mensaje al servidor de forma asincrónica
        // pero no esperamos la respuesta para actualizar la UI
        chatService
            .sendMessage(
                token, widget.conversationId, message, authService.user.id)
            .then((_) {
          // Opcional: Hacer algo cuando el mensaje se envía exitosamente
          print('Mensaje enviado con éxito');
        }).catchError((e) {
          // Manejo de errores
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al enviar mensaje: $e'),
                backgroundColor: Colors.red[100],
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Reintentar',
                  onPressed: () => _resendMessage(message),
                ),
              ),
            );
          }
        }).whenComplete(() {
          // Finalmente, actualizamos el estado de envío
          if (mounted) {
            setState(() {
              _isSending = false;
            });
          }
        });
      }
    } catch (e) {
      // Este try-catch es para errores que puedan ocurrir al iniciar la petición
      print('Error al iniciar el envío: $e');
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar el envío: $e'),
            backgroundColor: Colors.red[100],
          ),
        );
      }
    }
  }

  Future<void> _resendMessage(String messageText) async {
    if (messageText.isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);

    try {
      final token = authService.token;
      if (token != null) {
        await chatService.sendMessage(
            token, widget.conversationId, messageText, authService.user.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reenviar mensaje: $e')),
        );
      }
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
            onPressed: _isLoading
                ? null
                : _resetRetryCount, // Usar el método de reinicio
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
                    onPressed: _resetRetryCount, // Usar el método de reinicio
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
                          // Usar cacheExtent para mantener elementos fuera de pantalla en memoria
                          cacheExtent: 1000,
                          // Usar Automatic Keep Alive para mantener los widgets en memoria
                          addAutomaticKeepAlives: true,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final bool showTime = index == 0 ||
                                _shouldShowTime(messages[index],
                                    index > 0 ? messages[index - 1] : null);

                            // Usar key basada en mensaje para optimizar reconstrucción
                            return KeyedSubtree(
                              key: ValueKey(
                                  'msg_${message.id ?? message.time}_${message.text.hashCode}'),
                              child: MessageBubble(
                                message: message,
                                showTime: showTime,
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
                    onPressed: _isSending ? null : _sendMessage,
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
    if (previous == null) return true;

    // Si los mensajes son de diferentes usuarios, mostrar tiempo
    if (current.userId != previous.userId) return true;

    // Si hay más de 5 minutos entre mensajes, mostrar tiempo
    if (current.createdAt != null && previous.createdAt != null) {
      final difference = current.createdAt!.difference(previous.createdAt!);
      return difference.inMinutes > 5;
    }

    return false;
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTime;

  const MessageBubble({
    Key? key,
    required this.message,
    this.showTime = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      color: message.isMe ? Colors.orange : Colors.grey[200],
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
                      child: Text(
                        message.time,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.0,
                        ),
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
